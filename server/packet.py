import json
from typing import Any
from netbound.packet import BasePacket

class OkPacket(BasePacket):
    ...

class DenyPacket(BasePacket):
    reason: str

class PIDPacket(BasePacket):
    """Sent to the client to inform it of its PID (ascertained by `from_pid` property)"""
    ...
    
class HelloPacket(BasePacket):
    """Sent between protocols and to the client to convey essential information about the state of the sender, e.g. position, name, etc."""
    state_view: dict[str, Any]

class WhichUsernamesPacket(BasePacket):
    """Sent from a new connection to other protocols to ask for the usernames of all currently logged in users (to avoid double logins)"""
    ...

class MyUsernamePacket(BasePacket):
    """Sent to a protocol who has requested the username of the sender (via `WhichUsernamesPacket`)"""
    username: str

class MotdPacket(BasePacket):
    message: str

class MovePacket(BasePacket):
    dx: int
    dy: int

class LoginPacket(BasePacket):
    username: str
    password: str

class RegisterPacket(BasePacket):
    username: str
    password: str

class DisconnectPacket(BasePacket):
    reason: str

class ChatPacket(BasePacket):
    message: str

class MalformedPacketError(ValueError):
    pass

class UnknownPacketError(ValueError):
    pass
