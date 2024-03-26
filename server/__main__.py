import asyncio
import logging
import traceback
import argparse
from netbound.app import ServerApp
from server.state import EntryState, BobPlayState
from server import packet
from sqlalchemy.ext.asyncio import AsyncEngine, create_async_engine
from ssl import SSLContext, PROTOCOL_TLS_SERVER
from ssl import TLSVersion

def get_ssl_context(certpath: str, keypath: str) -> SSLContext:
    logging.info("Loading encryption key")
    ssl_context: SSLContext = SSLContext(PROTOCOL_TLS_SERVER)
    try:
        ssl_context.load_cert_chain(certpath, keypath)
    except FileNotFoundError:
        raise FileNotFoundError(f"No encryption key or certificate found. Please generate a pair and save them to {certpath} and {keypath}")

    return ssl_context

async def main(hostname: str, port: int) -> None:
    logging.info("Starting server")

    db_engine: AsyncEngine = create_async_engine("sqlite+aiosqlite:///server/database/database.sqlite3")

    # Generated with `mkcert -install` and `mkcert localhost 127.0.0.1 ::1` (need mkcert first)
    ssl_context: SSLContext = get_ssl_context("server/ssl/localhost+2.pem", "server/ssl/localhost+2-key.pem")

    # TLS 1.3 is not supported by Godot yet, so we need to force 1.2
    ssl_context.minimum_version = TLSVersion.TLSv1_2
    ssl_context.maximum_version = TLSVersion.TLSv1_2

    server_app: ServerApp = ServerApp(hostname, port, db_engine, ssl_context=ssl_context)

    server_app.register_packets(packet)

    await server_app.add_npc(BobPlayState)

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

    parser = argparse.ArgumentParser(description="Start the server")
    parser.add_argument("--hostname", type=str, default="localhost", help="Hostname to bind to")
    parser.add_argument("--port", type=int, default=9091, help="Port to bind to")
    args = parser.parse_args()

    try:
        asyncio.run(main(args.hostname, args.port))
    except KeyboardInterrupt:
        logging.info("Server stopped by user")
    except Exception as e:
        logging.error(f"Unexpected error: {e}")
        traceback.print_exc() 