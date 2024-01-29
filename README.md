This is a proof-of-concept for a multiplayer game using a GameMaker Studio 2 client, which freely supports HTML, mobile, and desktop platforms, and run by a Python server. The server is built using trio-websocket and is designed to be simple to understand, use, and extend. 

# Setup guide
1. Setup the virtual environment
   ```sh
   python -m venv server/venv
   ```
2. Activate the virtual environment
   ```sh
   source server/venv/bin/activate
   ```
   or for Windows, 
   ```sh
   server/venv/Scripts/activate
   ```
3. Install the dependencies
   ```sh
   pip install -r server/requirements.txt
   ```
4. Build the packet models
   ```sh
   datamodel-codegen --input shared/packet_definitions.json --output server/net/packets.py
   ```
5. Download [the latest .yymps for SNAP (data format converters for GameMaker)](https://github.com/JujuAdams/SNAP/releases) and import them into the GameMaker project as a local package.

6. Run the server
   ```sh
   python -m server
   ```