FROM ghcr.io/linuxserver/baseimage-alpine:3.20

# Copy the start script into the image
# COPY start.sh /usr/local/bin/start.sh

# Make the script executable
# RUN chmod +x /usr/local/bin/start.sh

# Set the script as the entrypoint
# ENTRYPOINT ["/usr/local/bin/start.sh"]

LABEL maintainer="Julio Gutierrez julio.guti+nordlynx@pm.me"

HEALTHCHECK CMD [ $(( $(date -u +%s) - $(wg show wg0 latest-handshakes | awk '{print $2}') )) -le 120 ] || exit 1

COPY /root /

# Convert files to Unix format
# Convert files to Unix format and set executable permissions
RUN find /etc/cont-init.d/ -type f -exec dos2unix {} + && \
    echo "Converted /etc/cont-init.d/ to Unix format" || echo "Failed to convert /etc/cont-init.d/ to Unix format"

RUN find /etc/services.d/ -type f -exec dos2unix {} + && \
    echo "Converted /etc/services.d/ to Unix format" || echo "Failed to convert /etc/services.d/ to Unix format"

RUN find /patch/ -type f -exec dos2unix {} + && \
    echo "Converted /patch/ to Unix format" || echo "Failed to convert /patch/ to Unix format"

RUN chmod +x /etc/cont-init.d/* && \
    echo "Set executable permissions on /etc/cont-init.d/*" || echo "Failed to set executable permissions on /etc/cont-init.d/*"

RUN chmod +x /etc/services.d/wireguard/* && \
    echo "Set executable permissions on /etc/services.d/wireguard/*" || echo "Failed to set executable permissions on /etc/services.d/wireguard/*"

RUN chmod +x /patch/* && \
    echo "Set executable permissions on /patch/*" || echo "Failed to set executable permissions on /patch/*"

# Install necessary packages and apply patches
RUN apk add --no-cache -U wireguard-tools curl jq patch bash iptables iptables-legacy && \
    echo "Installed necessary packages" || echo "Failed to install necessary packages"

RUN patch --verbose -d / -p 0 -i /patch/wg-quick.patch && \
    echo "Applied patch" || echo "Failed to apply patch"

RUN apk del --purge patch && \
    echo "Removed patch package" || echo "Failed to remove patch package"

RUN rm -rf /tmp/* /patch && \
    echo "Cleaned up temporary files" || echo "Failed to clean up temporary files"