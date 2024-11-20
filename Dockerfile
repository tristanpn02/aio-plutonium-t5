# Use an official Ubuntu image as the base
FROM ubuntu:20.04

# Set environment variables (avoiding hardcoding sensitive data like SERVER_KEY)
ENV DEBIAN_FRONTEND=noninteractive
ENV SERVER_PORT=28960
ENV SERVER_MODE=t5sp
ENV SERVER_CFG=dedicated_sp.cfg
ENV WINEPREFIX=/root/.wine
ENV DISPLAY=:0

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    wget \
    gnupg2 \
    software-properties-common \
    apt-transport-https \
    curl \
    aria2 \
    ufw \
    fail2ban \
    wine64 \
    screen \
    psmisc && \
    rm -rf /var/lib/apt/lists/*

# Copy the .env file into the container
COPY .env /root/.env

# Create directories for T5 server and Plutonium
RUN mkdir -p /root/T5Server/Plutonium /root/T5Server/Server

# Download Plutonium updater and game files
RUN cd /root/T5Server/Plutonium && \
    wget https://github.com/mxve/plutonium-updater.rs/releases/latest/download/plutonium-updater-x86_64-unknown-linux-gnu.tar.gz && \
    tar xfv plutonium-updater-x86_64-unknown-linux-gnu.tar.gz && \
    rm plutonium-updater-x86_64-unknown-linux-gnu.tar.gz

# Download the game files using aria2
RUN cd /root/T5Server && \
    wget https://web.archive.org/web/20230106045330mp_/https://www.plutonium.pw/pluto_t5_full_game.torrent && \
    aria2c --seed-time=0 --max-download-limit=0 -d /root/T5Server -T pluto_t5_full_game.torrent && \
    rm /root/T5Server/pluto_t5_full_game.torrent

# Copy the configuration file into the container
COPY dedicated_sp.cfg /root/T5Server/Server/dedicated_sp.cfg

# Ensure the server scripts are in place and make them executable
COPY T5_zm_server.sh /root/T5Server/Plutonium/T5_zm_server.sh
COPY T5_mp_server.sh /root/T5Server/Plutonium/T5_mp_server.sh
COPY restart.sh /root/T5Server/restart.sh
COPY allow_port.sh /root/T5Server/allow_port.sh

RUN chmod +x /root/T5Server/Plutonium/T5_zm_server.sh \
    && chmod +x /root/T5Server/Plutonium/T5_mp_server.sh \
    && chmod +x /root/T5Server/restart.sh \
    && chmod +x /root/T5Server/allow_port.sh

# Set up environment variables and configure them in the script
RUN echo 'source /root/.env' >> /root/.bashrc

# Expose the necessary ports
EXPOSE 28960/udp

# Default command to start the server in a screen session
CMD ["screen", "-S", "T5Server", "-dm", "/root/T5Server/Plutonium/T5_zm_server.sh"]
