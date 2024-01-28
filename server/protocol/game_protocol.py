"""
This module contains the game protocol used for communication between the server and clients.
"""
from __future__ import annotations
import logging
from queue import Queue
from typing import Optional
from trio_websocket import WebSocketConnection, ConnectionClosed
from server.protocol import states
from server.protocol.logging_adapter import ProtocolLoggerAdapter
import server.net.packets as packets
from server.net import serialize_packet, packet_from_bytes

class GameProtocol:
    """
    Represents the game protocol used for communication between the server and clients.
    """
    def __init__(self, server_stream: WebSocketConnection, 
                 connected_protocols: list[GameProtocol], ident: int) -> None:
        self._server_connection: WebSocketConnection = server_stream
        self._outgoing_packets: \
            Queue[tuple[GameProtocol, GameProtocol, packets.BaseModel]] = Queue()
        self.state: states.ProtocolState = states.EntryState(self)
        self._other_protocols: list[GameProtocol] = connected_protocols
        self._ident: int = ident

        self.username: Optional[str] = None

        # Give this protocol a unique identifier to improve logging
        self.logger = ProtocolLoggerAdapter(logging.getLogger(__name__), {
            'ident': self._ident,
            'state': self.state
        })

    async def start(self) -> None:
        """
        Starts the game protocol and handles incoming messages.

        This method continuously reads messages from the connection and handles them
        until the connection is closed or an exception occurs.

        Raises:
            Exception: If an error occurs while handling a message.
        """
        try:
            while True:
                data = await self._read_message()
                if data is None:
                    break
                self._handle_message(data)
        finally:
            self.logger.info("Stopped")
            self._other_protocols.remove(self)

    def set_state(self, state_cls: type[states.ProtocolState]) -> None:
        """
        Sets the protocol state to the specified state.

        Args:
            state_cls (type[states.ProtocolState]): The class of the state to set the protocol to.

        Returns:
            None

        Example:
            >>> protocol.set_state(PlayState)
        """
        if isinstance(self.state, state_cls):
            self.logger.warning(f"State already set to {self.state}")
            return

        if state_cls is states.ProtocolState:
            raise ValueError("Cannot set state to ProtocolState")

        new_state: states.ProtocolState = state_cls(self)
        self.logger.info(f"State changing to {new_state}")
        self.state = new_state
        self.logger.extra['state'] = new_state

    def queue_outbound_packet(self, sender: GameProtocol, recipient: GameProtocol, 
                              packet: packets.BaseModel) -> None:
        """
        Queues up a packet to send to another protocol on the next tick.

        Args:
            sender (GameProtocol): 
                The protocol that is sending the packet.
            recipient (GameProtocol): 
                The protocol to send the packet to. If this is the same as this protocol, the packet 
                will be sent directly to the connected client.
            packet (packets.BaseModel): 
                The packet to send.

        Returns:
            None
        """
        self._outgoing_packets.put((sender, recipient, packet))

    def broadcast_packet(self, packet: packets.BaseModel, include_self: bool = False, 
                     states_whitelist=None) -> None:
        """
        Queues a packet on all connected protocols' outgoing packet queues, optionally including 
        this protocol.

        Args:
            packet (packets.BaseModel): 
                The packet to broadcast.
            include_self (bool): 
                Whether to include this protocol in the broadcast. Defaults to False.
            states_whitelist (list[type[states.ProtocolState]]):
                If supplied, only protocols with a state in this list will receive the packet.

        Returns:
            None
        """
        def _is_recipient_eligible(recipient):
            if recipient is self and not include_self:
                return False
            if states_whitelist:
                return any(isinstance(recipient.state, state) for state in states_whitelist)
            return True

        for recipient in self._other_protocols:
            if _is_recipient_eligible(recipient):
                recipient.queue_outbound_packet(self, recipient, packet)


    async def tick(self) -> None:
        """
        Sends the packet at the front of the outgoing packet queue to its destination.
        """
        if self._outgoing_packets.empty():
            return

        sender, recipient, packet = self._outgoing_packets.get()
        if sender is self and recipient is self:
            await self._send_packet(packet)
        elif recipient is self:
            self._handle_packet(sender, packet)
        else:
            recipient.queue_outbound_packet(sender, recipient, packet)

    async def _send_packet(self, packet: packets.BaseModel) -> None:
        self.logger.info(f"Sending packet: {packet.__class__.__name__}: ({packet})")
        await self._send_message(serialize_packet(packet))

    async def _read_message(self) -> Optional[bytes]:
        try:
            return await self._server_connection.get_message()

        except ConnectionClosed:
            self.logger.info("Connection closed on read")
            return None

        except Exception as exc:
            self.logger.error(f"Read error: {exc}")
            raise exc

    async def _send_message(self, message: bytes) -> None:
        try:
            await self._server_connection.send_message(message)
        except ConnectionClosed:
            self.logger.warning("Connection closed on send")
        except Exception as exc:
            self.logger.error(f"Send error: {exc}")
            raise exc

    def _handle_message(self, data: bytes) -> None:
        packet: packets.BaseModel = packet_from_bytes(data)
        
        self._handle_packet(self, packet)

    def _handle_packet(self, sender: GameProtocol, packet: packets.BaseModel) -> None:
        packet_name: str = packet.__class__.__name__.lower()
        handler_name: str = f"handle_{packet_name}_packet"

        try:
            handler: callable = getattr(self.state, handler_name)
        except AttributeError:
            self.logger.error(f"State {self.state} does not implement {handler_name}")
            return

        try:
            handler(sender, packet)
        except TypeError as exc:
            self.logger.warning(f"State {self.state} does not implement {handler_name}, {exc}")