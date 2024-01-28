"""
ProtocolState is an abstract class that represents a state in the protocol. Each state is used for 
handling packets that are sent/received in a specific context. For example, the EntryState is used 
for handling packets that are sent/received before the player has logged in. This way, we can 
separate the logic for handling packets into different states, which makes it easier to manage and 
maintain the code.
"""
from __future__ import annotations
from abc import ABC
from typing import TYPE_CHECKING
from server.net import deny
import server.net.packets as packets
if TYPE_CHECKING:
    from server.protocol import GameProtocol

class ProtocolState(ABC):
    """
    Abstract protocol state class. This class is used for handling packets that are sent/received in 
    a specific context. Implementations of this class should override the handle_*_packet methods.
    """
    def __init__(self, protocol: GameProtocol):
        self.proto = protocol

    def _log_unregistered_packet(self, packet: packets.BaseModel):
        self.proto.logger.warning(f"Received {packet.name} packet in unregistered state")
        d: packets.Deny = deny("You cannot perform this action")
        self.proto.queue_outbound_packet(self.proto, d)

    # Maintain all handle_*_packet methods in alphabetical order. This means classes that inherit
    # from this class will have the deny packet handler by default, unless they specifically
    # override it.

    # pylint: disable=missing-function-docstring
    def handle_ok_packet(self, sender: GameProtocol, packet: packets.Ok):
        self._log_unregistered_packet(packet)
    def handle_deny_packet(self, sender: GameProtocol, packet: packets.Deny):
        self._log_unregistered_packet(packet)
    def handle_chat_packet(self, sender: GameProtocol, packet: packets.Chat):
        self._log_unregistered_packet(packet)
    def handle_hello_packet(self, sender: GameProtocol, packet: packets.Hello):
        self._log_unregistered_packet(packet)
    def handle_login_packet(self, sender: GameProtocol, packet: packets.Login):
        self._log_unregistered_packet(packet)
    def handle_logout_packet(self, sender: GameProtocol, packet: packets.Logout):
        self._log_unregistered_packet(packet)
    def handle_move_packet(self, sender: GameProtocol, packet: packets.Move):
        self._log_unregistered_packet(packet)
    def handle_register_packet(self, sender: GameProtocol, packet: packets.Register):
        self._log_unregistered_packet(packet)
    # pylint: enable=missing-function-docstring

    def __str__(self):
        return self.__class__.__name__

    def __repr__(self):
        return str(self)