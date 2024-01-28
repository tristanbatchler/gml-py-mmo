"""
Entry state for the protocol. This state is used for handling packets that are sent/received before 
the player has logged in.
"""
from server.net import deny, ok
from server.protocol.states.protocol_state import ProtocolState
import server.protocol.states as states
import server.net.packets as packets

class EntryState(ProtocolState):
    """
    Represents the entry state of the protocol.

    This state handles packets that are sent/received before the player has logged in.
    """
    def handle_chat_packet(self, packet: packets.Chat) -> None:
        d: packets.Deny = deny("You must be logged in to chat")
        self.proto.queue_outbound_packet(self.proto, d)

    def handle_login_packet(self, packet: packets.Login) -> None:
        self.proto.username = packet.username

        o: packets.Ok = ok("You have successfully logged in")
        self.proto.queue_outbound_packet(self.proto, o)
        self.proto.set_state(states.PlayState)

    def handle_register_packet(self, packet: packets.Register) -> None:
        pass
