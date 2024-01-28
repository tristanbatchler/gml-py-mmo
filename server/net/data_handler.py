from __future__ import annotations
import json, jsonschema
import msgpack
import server.net.packets as packets

# Store the packet definitions from the shared/packet_definitions.json schema file.
# This is used to validate incoming packets.
definitions = {}
with open("shared/packet_definitions.json") as f:
    definitions = json.load(f)

def validate(data: dict):
    """
    Validates the specified packet against the packet schema.

    Args:
        packet (dict): The packet to validate.

    Raises:
        jsonschema.exceptions.ValidationError: If the packet is not valid.
    """
    jsonschema.validate(data, definitions)

def packet_from_bytes(data: bytes) -> packets.BaseModel:
    """
    Deserializes a packet from the specified messagepack bytes.

    Args:
        data (bytes): The bytes to deserialize.

    Returns:
        Packet: The deserialized packet.

    Raises:
        msgpack.exceptions.ExtraData: If there is extra data in the packet.
        msgpack.exceptions.UnpackValueError: If the packet is invalid.
        jsonschema.exceptions.ValidationError: If the packet is not valid.
    """
    data = msgpack.unpackb(data, raw=False)
    validate(data)
    
    # Use reflection to get the exact packet type from the packet name.
    packet_name = list(data.keys())[0].capitalize()
    packet_type = getattr(packets, packet_name)
    packet = packet_type(**data[packet_name])
    return packet


def serialize_packet(packet: packets.BaseModel) -> bytes:
    """
    Serializes the packet to messagepack bytes.

    Returns:
        bytes: The serialized packet.

    Raises:
        jsonschema.exceptions.ValidationError: If the packet is not valid.
    """
    data = {}
    packet_name = packet.__class__.__name__.capitalize()
    m_dump = packet.model_dump()
    data[packet_name] = m_dump
    validate(data)
    return msgpack.packb(data, use_bin_type=True)