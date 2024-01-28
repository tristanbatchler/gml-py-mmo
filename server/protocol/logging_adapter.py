"""
Logging adapter for protocol messages.
"""
import logging
from typing import Optional
from server.protocol.states import ProtocolState

class ProtocolLoggerAdapter(logging.LoggerAdapter):
    """
    Adapter class for logging protocol messages with additional information.

    This class extends the `logging.LoggerAdapter` class and provides a `process` method
    to add extra information to the log messages. The extra information includes the
    protocol identifier and state.

    Attributes:
        extra (dict): A dictionary containing the extra information to be added to the log messages.
    """

    def process(self, msg, kwargs):
        protocol_ident: int = self.extra.get('ident', -1)
        protocol_state: Optional[ProtocolState] = self.extra.get('state', None)
        return f"[#{protocol_ident:04d}][{protocol_state}] {msg}", kwargs