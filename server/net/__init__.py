"""
This module contains all network packet-related logic.
"""
from server.net.packets import Deny, Ok
from server.net.data_handler import packet_from_bytes, serialize_packet

def deny(reason: str) -> Deny:
    return Deny(reason=reason)

def ok(message: str = None) -> Ok:
    return Ok(message=message)