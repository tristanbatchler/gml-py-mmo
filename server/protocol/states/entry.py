"""
Entry state for the protocol. This state is used for handling packets that are sent/received before 
the player has logged in.
"""
from __future__ import annotations
from typing import TYPE_CHECKING
from server.net import deny, ok
from server.protocol.states.protocol_state import ProtocolState
import server.protocol.states as states
import server.net.packets as packets
if TYPE_CHECKING:
    from server.protocol.game_protocol import GameProtocol

class EntryState(ProtocolState):
    """
    Represents the entry state of the protocol.

    This state handles packets that are sent/received before the player has logged in.
    """
    def handle_chat_packet(self, sender: GameProtocol, packet: packets.Chat) -> None:
        d: packets.Deny = deny("You must be logged in to chat")
        self.proto.queue_outbound_packet(self.proto, self.proto, d)

    def handle_login_packet(self, sender: GameProtocol, packet: packets.Login) -> None:
        self.proto.username = packet.username

        o: packets.Ok = ok("You have successfully logged in")
        self.proto.queue_outbound_packet(self.proto, self.proto, o)

        self.proto.set_state(states.PlayState)
        h: packets.Hello = packets.Hello(username=packet.username, x=50, y=50)
        self.proto.broadcast_packet(h, include_self=True, states_whitelist=[states.PlayState])

    def handle_register_packet(self, sender: GameProtocol, packet: packets.Register) -> None:
        pass
