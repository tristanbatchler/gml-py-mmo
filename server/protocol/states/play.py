"""
Play state for the protocol. This state is used for chatting and other in-game actions.
"""
from __future__ import annotations
from typing import TYPE_CHECKING
from server.net import deny, ok
from server.protocol.states.protocol_state import ProtocolState
import server.protocol.states as states
import server.net.packets as packets

if TYPE_CHECKING:
    from server.protocol.game_protocol import GameProtocol

class PlayState(ProtocolState):
    """
    Represents the play state of the protocol.

    This state handles packets that are sent/received after the player has logged in.
    """
    def handle_chat_packet(self, sender: GameProtocol, packet: packets.Chat) -> None:
        if sender is self.proto:
            self.proto.broadcast_packet(packet, include_self=True, 
                                        states_whitelist=[states.PlayState])
        else:
            self.proto.queue_outbound_packet(self.proto, self.proto, packet)

    def handle_logout_packet(self, sender: GameProtocol, packet: packets.Logout) -> None:
        if self.proto.username == packet.username:
            self.proto.set_state(states.EntryState)
            o: packets.Ok = ok("You have successfully logged out")
            self.proto.queue_outbound_packet(self.proto, self.proto, o)

            # Let other players know that this player has logged out
            self.proto.broadcast_packet(packet)

        else:
            self.proto.queue_outbound_packet(sender, self.proto, packet)

    def handle_hello_packet(self, sender: GameProtocol, packet: packets.Hello) -> None:
        self.proto.queue_outbound_packet(self.proto, self.proto, packet)

        if sender is not self.proto:
            h: packets.Hello = packets.Hello(username=self.proto.username, 
                                             x=self.proto._x, y=self.proto._y)
            sender.queue_outbound_packet(sender, sender, h)
        

    def handle_move_packet(self, sender: GameProtocol, packet: packets.Move) -> None:
        if sender is self.proto:
            self.proto.update_input(packet.x, packet.y)
            self.proto.broadcast_packet(packet, states_whitelist=[states.PlayState])
        else:
            self.proto.queue_outbound_packet(self.proto, self.proto, packet)