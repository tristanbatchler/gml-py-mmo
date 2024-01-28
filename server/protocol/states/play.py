"""
Play state for the protocol. This state is used for chatting and other in-game actions.
"""
from server.net import deny, ok
from server.protocol.states.protocol_state import ProtocolState
import server.protocol.states as states
import server.net.packets as packets

class PlayState(ProtocolState):
    """
    Represents the play state of the protocol.

    This state handles packets that are sent/received after the player has logged in.
    """
    def handle_chat_packet(self, packet: packets.Chat) -> None:
        self.proto.broadcast_packet(packet, include_self=True, 
                                    states_whitelist=[states.PlayState])

    def handle_logout_packet(self, packet: packets.Logout) -> None:
        if self.proto.username == packet.username:
            self.proto.set_state(states.EntryState)
            o: packets.Ok = ok("You have successfully logged out")
            self.proto.queue_outbound_packet(self.proto, o)

            # Let other players know that this player has logged out
            self.proto.broadcast_packet(packet)

        else:
            self.proto.queue_outbound_packet(self.proto, packet)