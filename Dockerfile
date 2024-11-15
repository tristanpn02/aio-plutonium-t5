FROM ubuntu:jammy

LABEL author="Tristan Andersen"


################################################################################
#                             Environment Variables                            #
################################################################################
ENV PLUTONIUM_DIRECTORY="/t5server/plutonium"
ENV SERVER_DIRECTORY="/t5server/server"
ENV IW4ADMIN_DIRECTORY="/t5server/admin"
ENV UPDATER_DIRECTORY="/t5server/updater"
ENV DOWNLOAD_DIRECTORY="/t5server/downloaded_files"
ENV STATUS_DIRECTORY="/t5server/status"

ENV WINEPREFIX="/root/.wine"
ENV WINEDEBUG="fixme-all"
ENV WINEARCH="win64"

ENV SERVER_KEY="YOUR_KEY_HERE"
ENV SERVER_PORT="4976"
ENV SERVER_MODE="Zombie"
ENV LAN_MODE="false"

ENV SERVER_MAX_CLIENTS=""
ENV SERVER_RCON_PASSWORD="admin"
ENV SERVER_MAP_ROTATION=""
ENV SERVER_PASSWORD=""

ENV ADMIN_PORT="1624"

################################################################################
#                            Container Provisioning                            #
################################################################################

# Create needed directories
RUN mkdir -p $PLUTONIUM_DIRECTORY \
			 $SERVER_DIRECROTY \
			 $IW4ADMIN_DIRECTORY \
			 $UPDATER_DIRECTORY \
			 $DOWNLOAD_DIRECTORY \
			 $STATUS_DIRECTORY

# Update the system
RUN apt-get update

# Installing needed packages
RUN apt-get install -y \
	wget \
	curl \
	zip \
	screen \
	gnupg2 \
	software-properties-common \
	xvfb \
	aria2 \
	apt-transport-https \
	dotnet6 \
	dotnet-sdk-6.0 \
	aspnetcore-runtime-6.0 \
	avahi-daemon \
	avahi-utils

# Update the system
RUN apt-get upgrade -y

# Add Microsoft Package Signing Key and Repository
# And install ASP.NEY Core Runtime Version 8.0
RUN wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y aspnetcore-runtime-8.0 && \
    rm packages-microsoft-prod.deb

################################################################################
#                               Installing WINE                                #
################################################################################

COPY resources/install_wine.sh /t5server/install_wine.sh 
RUN chmod +x /t5server/install_wine.sh 
# [TODO] Run installer of the script in the server-launch.sh
RUN bash /t5server/install_wine.sh  && rm /t5server/install_wine.sh 


################################################################################
#                             Installing Updater                               #
################################################################################

COPY resources/check_updater.sh /t5server/check_updater.sh
#Make sure the script is executable by anyone
RUN chmod ugo+x /t5server/check_updater.sh


################################################################################
#                             Installing IW4MAdmin                             #
################################################################################

# Installing dotnet
RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
  dpkg -i packages-microsoft-prod.deb && \
  rm packages-microsoft-prod.deb


################################################################################



# Prepare server launch
WORKDIR /t5server
COPY resources/server-launch.sh .
RUN chmod +x server-launch.sh

CMD ["./server-launch.sh"]
