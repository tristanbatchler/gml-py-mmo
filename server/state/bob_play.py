from __future__ import annotations
from netbound import schedule
from netbound.state import BaseState
from server.packet import ChatPacket, DisconnectPacket, HelloPacket, MovePacket, MyUsernamePacket, WhichUsernamesPacket
from netbound.constants import EVERYONE
from server.state import LoggedState
from random import randint, uniform, choice

class BobPlayState(LoggedState):
    def __init__(self, *args, **kwargs) -> None:
        super().__init__(*args, **kwargs)
        self._queue_local_client_send = lambda p: self._logger.warning(f"NPC tried to send packet to client: {p}")

    async def _on_transition(self, previous_state_view: BaseState.View | None = None) -> None:
        self._name = "Bob"
        self._x = randint(0, 10) * 32
        self._y = randint(0, 7) * 32
        self._image_index = 3
        await self._queue_local_protos_send(HelloPacket(from_pid=self._pid, to_pid=EVERYONE, exclude_sender=True, state_view=self.view_dict))
        self._logger.info(f"Bob spawned at ({self._x}, {self._y})")
        await self._random_move()

    async def _random_move(self) -> None:
        # Only a chance of moving
        if not randint(0, 3):
            dx: int = choice((-1, 1)) * 32
            dy: int = choice((-1, 1)) * 32

            if dy and dx:
                # Only move in one direction at a time
                if randint(0, 1):
                    dx = 0
                else:
                    dy = 0
            
            if self._x + dx < 0 or self._x + dx >= 320:
                dx = -dx
            if self._y + dy < 0 or self._y + dy >= 224:
                dy = -dy
            self._x += dx
            self._y += dy

            if len(self._known_others) > 0:
                await self._queue_local_protos_send(MovePacket(from_pid=self._pid, to_pid=self._known_others.keys(), dx=dx, dy=dy))

        # Schedule the next move, so Bob is always moving around
        next_move_timer: float = uniform(0, 2.5)
        schedule(next_move_timer, self._random_move)


    async def handle_chat(self, p: ChatPacket) -> None:
        if p.from_pid in self._known_others:
            sender_view: BaseState.View = self._known_others[p.from_pid]
            if sender_view.name:
                reply: str = f"Hi {sender_view.name}! I'm Bob!"
                schedule(1, lambda: self._queue_local_protos_send(ChatPacket(from_pid=self._pid, to_pid=EVERYONE, exclude_sender=True, message=reply)))

    async def handle_disconnect(self, p: DisconnectPacket) -> None:
        if p.from_pid in self._known_others:
            disconnecting_view: BaseState.View | None = self._known_others.pop(p.from_pid, None)
            if disconnecting_view and disconnecting_view.name:
                await self._queue_local_protos_send(ChatPacket(from_pid=self._pid, to_pid=EVERYONE, exclude_sender=True, message=f"Bye {disconnecting_view.name}!"))

    async def handle_hello(self, p: HelloPacket) -> None:
        if p.from_pid not in self._known_others:
            # Record information about the other protocol
            self._known_others[p.from_pid] = LoggedState.View(**p.state_view)

            # Tell the other protocol about us
            await self._queue_local_protos_send(HelloPacket(from_pid=self._pid, to_pid=p.from_pid, state_view=self.view_dict))

    async def handle_move(self, p: MovePacket) -> None:
        if p.from_pid in self._known_others:
            other: LoggedState.View = self._known_others[p.from_pid]
            other.x += p.dx
            other.y += p.dy
            
    # If some protocol is requesting our username, send it to them (this is in response to a `WhichUsernamesPacket` sent by a new connection)
    async def handle_whichusernames(self, p: WhichUsernamesPacket) -> None:
        assert self._name
        await self._queue_local_protos_send(MyUsernamePacket(from_pid=self._pid, to_pid=p.from_pid, username=self._name))