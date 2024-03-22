import asyncio
import logging
import traceback
from netbound.app import ServerApp
from server.state import EntryState
from server import packet
from sqlalchemy.ext.asyncio import AsyncEngine, create_async_engine
from ssl import SSLContext, PROTOCOL_TLS_SERVER

def get_ssl_context(certpath: str, keypath: str) -> SSLContext:
    logging.info("Loading encryption key")
    ssl_context: SSLContext = SSLContext(PROTOCOL_TLS_SERVER)
    try:
        ssl_context.load_cert_chain(certpath, keypath)
    except FileNotFoundError:
        raise FileNotFoundError(f"No encryption key or certificate found. Please generate a pair and save them to {certpath} and {keypath}")

    return ssl_context

async def main() -> None:
    logging.info("Starting server")

    db_engine: AsyncEngine = create_async_engine("sqlite+aiosqlite:///server/database/database.sqlite3")
    ssl_context: SSLContext = get_ssl_context("server/ssl/localhost.crt", "server/ssl/localhost.key")
    server_app: ServerApp = ServerApp("localhost", 443, db_engine, ssl_context=ssl_context)

    server_app.register_packets(packet)

    async with asyncio.TaskGroup() as tg:
        tg.create_task(server_app.start(initial_state=EntryState))
        tg.create_task(server_app.run(ticks_per_second=10))


    logging.info("Server stopped")


if __name__ == "__main__":

    logging.basicConfig(level=logging.INFO)
    
    # Silence SQLAlchemy logging
    sqlalchemy_engine_logger = logging.getLogger('sqlalchemy.engine')
    sqlalchemy_engine_logger.setLevel(logging.WARNING)


    # Set format for logging
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    for handler in logging.getLogger().handlers:
        handler.setFormatter(formatter)

    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logging.info("Server stopped by user")
    except Exception as e:
        logging.error(f"Unexpected error: {e}")
        traceback.print_exc() 