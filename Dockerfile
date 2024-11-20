# Use an official Ubuntu image as the base
FROM ubuntu:20.04

# Set environment variables
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
    transmission-cli \
    ufw \
    fail2ban \
    wine64 \
    screen \
    psmisc && \  # Install psmisc for killall command
    rm -rf /var/lib/apt/lists/*

# Enable 32-bit architecture support
RUN dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get install -y \
    lib32z1 \
    lib32ncurses6 \
    lib32stdc++6

# Install WineHQ
RUN wget -nc https://dl.winehq.org/wine-builds/winehq.key && \
    apt-key add winehq.key && \
    apt-add-repository 'deb https://dl.winehq.org/wine-builds/debian/ buster main' && \
    rm winehq.key && \
    apt-get update -y && \
    apt install --install-recommends winehq-stable -y

# Create directories for T5 server and Plutonium
RUN mkdir -p /root/T5Server/Plutonium /root/T5Server/Server

# Download Plutonium updater and game files
RUN cd /root/T5Server/Plutonium && \
    wget https://github.com/mxve/plutonium-updater.rs/releases/latest/download/plutonium-updater-x86_64-unknown-linux-gnu.tar.gz && \
    tar xfv plutonium-updater-x86_64-unknown-linux-gnu.tar.gz && \
    rm plutonium-updater-x86_64-unknown-linux-gnu.tar.gz

# Download the game files (simulating a torrent download)
RUN cd /root/T5Server && \
    wget https://web.archive.org/web/20230106045330mp_/https://www.plutonium.pw/pluto_t5_full_game.torrent && \
    tmpfile=$(mktemp) && \
    chmod a+x $tmpfile && \
    echo "killall transmission-cli" > $tmpfile && \
    transmission-cli -f $tmpfile pluto_t5_full_game.torrent -w /root/T5Server && \
    rm /root/T5Server/pluto_t5_full_game.torrent

# Clean Installation: Move game files to Server folder and remove unnecessary files
RUN mv /root/T5Server/pluto_t5_full_game /root/T5Server/Server && \
    rm -r /root/T5Server/Server/redist && \
    rm /root/T5Server/README.md

# Make the game startup scripts executable
RUN chmod +x /root/T5Server/Plutonium/T5_zm_server.sh /root/T5Server/Plutonium/T5_mp_server.sh

# Setup the screen environment and run the server
RUN echo 'export WINEPREFIX=/root/.wine' >> /root/.bashrc && \
    echo 'export DISPLAY=:0' >> /root/.bashrc

# Expose the necessary ports
EXPOSE 28960/udp

# Set the default command to start the server in a screen session
CMD ["screen", "-S", "T5Server", "-dm", "/root/T5Server/Plutonium/T5_zm_server.sh"]
