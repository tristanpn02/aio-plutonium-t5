# AIO-Plutonium-T5 - All-in-One Plutonium Server

This repository contains files and instructions for building and running a [Plutonium](https://plutonium.pw) server with an integrated [IW4Admin](https://github.com/RaidMax/IW4M-Admin) panel within Docker.

This solution is designed to simplify the process of hosting a LAN or WAN server by automating the setup.

> **Note:** This repository is based on a fork of [thejcpalma's AIO-Plutonium-T6 project](https://github.com/thejcpalma/aio-plutonium-t6).

- Currently tested on Linux and Windows; it should run on any system that supports Docker.
- Tested in LAN environments (accessible via reverse proxy for WAN) and Zombie mode, though it may also support Multiplayer.

## Setup

### Requirements
- **Docker**: Installation instructions available [here](https://docs.docker.com/get-docker/).

## Installation

### 1. Build the Docker Image
To build the Docker image, run:
```bash
docker build -t aio-plutonium-t5 .
```

### 2. Create a Docker Volume
Create a Docker volume to store server files for persistence:
```bash
docker volume create aio-plutonium-t5
```

### 3. Launch the Server

With the volume created, you can now launch the server.

**To launch in online mode:**
```bash
docker run -d --name aio-plutonium-t5-server \
           -p 4976:4976/udp \
           -p 1624:1624/tcp \
           -v aio-plutonium-t5:/t5server \
           -e SERVER_KEY="your_server_key" \
           -e SERVER_RCON_PASSWORD="admin" \
           -e SERVER_MAX_CLIENTS="7" \
           -e SERVER_PASSWORD="1234"
```

**To launch in LAN mode:**
```bash
docker run -d --name aio-plutonium-t5-server \
           -p 4976:4976/udp \
           -p 1624:1624/tcp \
           -v aio-plutonium-t5:/t6server \
           -e LAN_MODE="true" \
           -e SERVER_RCON_PASSWORD="admin" \
           -e SERVER_MAX_CLIENTS="8" \
           -e SERVER_MAP_ROTATION='sv_maprotation "exec zm_classic_transit.cfg map zm_transit"' \
           -e SERVER_PASSWORD="1234"
```

### 4. Setup IW4MAdmin

Once the server is running, you need to configure the IW4Admin panel.

1. Attach to the `admin-panel` screen process within the container:
   ```bash
   docker exec -it aio-plutonium-t5-server /bin/bash -c "screen -r admin-panel"
   ```
2. Follow the initial configuration steps for [IW4Admin](https://github.com/RaidMax/IW4M-Admin/wiki/Configuration).
3. After setup, detach from the screen session by pressing `Ctrl+A`, then `Ctrl+D`.

Access IW4Admin in your browser at `http://hostname:1624`, where `hostname` is the host IP address.

## Environment Variables

### Fixed Environment Variables
Changing these may disrupt the server setup.

| **Variable**          | **Default**               |
|-----------------------|---------------------------|
| `PLUTONIUM_DIRECTORY` | `/t5server/plutonium`     |
| `SERVER_DIRECTORY`    | `/t5server/server`        |
| `IW4ADMIN_DIRECTORY`  | `/t5server/admin`         |
| `UPDATER_DIRECTORY`   | `/t5server/updater`       |
| `DOWNLOAD_DIRECTORY`  | `/t5server/downloaded_files` |
| `STATUS_DIRECTORY`    | `/t5server/status`        |

### Configurable Environment Variables

| **Variable**             | **Default**                   | **Description**                                                                                         |
|--------------------------|-------------------------------|---------------------------------------------------------------------------------------------------------|
| `SERVER_KEY`             | your_plutonium_server_key     | Server key from [Plutonium](https://plutonium.pw).                                                      |
| `SERVER_PORT`            | 4976                          | Game server port (UDP).                                                                                 |
| `SERVER_MODE`            | Zombie                        | Game mode, `Zombie` or `Multiplayer`.                                                                   |
| `LAN_MODE`               | false                         | Set to `true` for LAN mode.                                                                             |
| `SERVER_MAX_CLIENTS`     |                               | Max clients, 1-8. Default is 4.                                                                         |
| `SERVER_MAP_ROTATION`    |                               | String for map rotation (valid `sv_maprotation` configuration).                                         |
| `SERVER_RCON_PASSWORD`   | admin                         | RCON password. Default is `admin`.                                                                      |
| `SERVER_PASSWORD`        |                               | Server password.                                                                                        |
| `ADMIN_PORT`             | 1624                          | Admin panel port (TCP).                                                                                 |

## Credits

This project integrates resources from:
- [Plutonium](https://plutonium.pw) for server files.
- [IW4Admin](https://github.com/RaidMax/IW4M-Admin) for the admin panel.
- [plutonium-updater.rs](https://github.com/mxve/plutonium-updater.rs) by [mxve](https://github.com/mxve).
- [T6ServerConfigs](https://github.com/xerxes-at/T6ServerConfigs) by [xerxes-at](https://github.com/xerxes-at).

Special thanks to:
- [GaryCraft](https://github.com/GaryCraft) and [rexlManu](https://github.com/rexlManu) for their contributions to Docker-based Plutonium servers. 

