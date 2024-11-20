# Use an official Ubuntu image as the base
FROM ubuntu:20.04

# Set environment variables (avoiding hardcoding sensitive data)
ENV DEBIAN_FRONTEND=noninteractive \
    SERVER_PORT=28960 \
    SERVER_MODE=t5sp \
    SERVER_CFG=dedicated_sp.cfg \
    WINEPREFIX=/root/.wine \
    DISPLAY=:0

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    wget gnupg2 software-properties-common apt-transport-https \
    curl aria2 ufw fail2ban wine64 screen psmisc && \
    rm -rf /var/lib/apt/lists/*

# Create directories for T5 server and Plutonium
RUN mkdir -p /root/T5Server/Plutonium /root/T5Server/Server

# Download and install the Plutonium updater
RUN cd /root/T5Server/Plutonium && \
    wget https://github.com/mxve/plutonium-updater.rs/releases/latest/download/plutonium-updater-x86_64-unknown-linux-gnu.tar.gz && \
    tar -xvf plutonium-updater-x86_64-unknown-linux-gnu.tar.gz && \
    rm plutonium-updater-x86_64-unknown-linux-gnu.tar.gz

# Download game files and extract directly into the Server directory
RUN cd /root/T5Server && \
    wget https://web.archive.org/web/20230106045330mp_/https://www.plutonium.pw/pluto_t5_full_game.torrent && \
    aria2c --seed-time=0 --max-download-limit=0 -T pluto_t5_full_game.torrent && \
    tar -xvf pluto_t5_full_game.tar -C /root/T5Server/Server/ && \
    rm pluto_t5_full_game.torrent pluto_t5_full_game.tar

# Copy configuration and scripts
COPY configs/dedicated_sp.cfg /root/T5Server/Server/
COPY scripts/T5_zm_server.sh /root/T5Server/Plutonium/
RUN chmod +x /root/T5Server/Plutonium/T5_zm_server.sh

# Expose the necessary ports
EXPOSE 28960/udp

# Default command to start the server in a screen session
CMD ["screen", "-S", "T5Server", "-dm", "/root/T5Server/Plutonium/T5_zm_server.sh"]
