from server.state import BaseState
from server.packet import OkPacket, DenyPacket, LoginPacket, RegisterPacket, PIDPacket, WhichUsernamesPacket, MyUsernamePacket, MotdPacket
from server.database.model import User, Entity, InstancedEntity, Player
from sqlalchemy import select
from dataclasses import dataclass
from netbound.constants import EVERYONE
from random import randint
import bcrypt
from time import time
from datetime import datetime as dt

class EntryState(BaseState):
    @dataclass
    class View(BaseState.View):
        username: str

    def __init__(self, *args, **kwargs) -> None:
        super().__init__(*args, **kwargs)
        self._username: str | None = None
        self._last_failed_login_attempt: float = 0  # To rate limit login attempts
        self._usernames_already_logged_in: set[str] = set()  # To avoid double logins

    async def _on_transition(self, previous_state_view: BaseState.View | None = None) -> None:
        await self._queue_local_client_send(PIDPacket(from_pid=self._pid))
        now: dt = dt.now()

        message: str = "Welcome"
        if previous_state_view:
            message += " back"
            try:
                message += f", {previous_state_view.name}"
            except AttributeError:
                pass
        message += f"! It is currently {now.strftime('%A, %B %d %I:%M %p')}--what a time to be alive!"

        await self._queue_local_client_send(MotdPacket(from_pid=self._pid, message=message))

        # Send out a request for all currently logged in usernames (to avoid double logins)
        await self._queue_local_protos_send(WhichUsernamesPacket(from_pid=self._pid, to_pid=EVERYONE, exclude_sender=True))

    # Listen for other protocol's response to our `WhichUsernamesPacket`
    async def handle_myusername(self, p: MyUsernamePacket) -> None:
        self._usernames_already_logged_in.add(p.username)

    async def handle_login(self, p: LoginPacket) -> None:
        # Rate limit login attempts
        if time() - self._last_failed_login_attempt < 5:
            await self._queue_local_client_send(DenyPacket(from_pid=self._pid, reason="Too many failed login attempts. Please wait a few seconds before trying again."))
            self._logger.warning(f"Too many failed login attempts from {self._pid.hex()}")
            return
        
        # Check if user is already logged in
        if p.username in self._usernames_already_logged_in:
            await self._queue_local_client_send(DenyPacket(from_pid=self._pid, reason="This user is already logged in"))
            return

        async with self._get_db_session() as session:
            user: User = (await session.execute(select(User).where(User.username == p.username))).scalar_one_or_none()
            if user and bcrypt.checkpw(p.password.encode(), user.password.encode()):
                from server.state import LoggedState
                self._username = p.username
                await self._queue_local_client_send(OkPacket(from_pid=self._pid))
                await self.change_states(LoggedState)
            else:
                await self._queue_local_client_send(DenyPacket(from_pid=self._pid, reason="Invalid username or password"))
                self._last_failed_login_attempt = time()

    async def handle_register(self, p: RegisterPacket) -> None:
        async with self._get_db_session() as session:
            if (await session.execute(select(User).where(User.username == p.username))).scalar_one_or_none():
                await self._queue_local_client_send(DenyPacket(from_pid=self._pid, reason="Username already taken"))
            else:
                salt = bcrypt.gensalt()
                password_hash = bcrypt.hashpw(p.password.encode(), salt).decode()
                user: User = User(username=p.username, password=password_hash)
                self._logger.info(f"Registering new user {user}")
                entity: Entity = Entity(name=p.username)
                
                session.add(user)
                session.add(entity)
                await session.commit()

                room_width: int = 320
                room_height: int = 240
                grid_size: int = 16
                random_x: int = grid_size * randint(1, room_width // grid_size - 1)
                random_y: int = grid_size * randint(1, room_height // grid_size - 1)
                instanced_entity: InstancedEntity = InstancedEntity(entity_id=entity.id, x=random_x, y=random_y)
                
                session.add(instanced_entity)
                await session.commit()

                player: Player = Player(entity_id=entity.id, instanced_entity_id=instanced_entity.entity_id, user_id=user.id, image_index=randint(0, 17))

                session.add(player)
                await session.commit()

                await self._queue_local_client_send(OkPacket(from_pid=self._pid))