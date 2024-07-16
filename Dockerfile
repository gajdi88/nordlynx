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
RUN find /etc/cont-init.d/ -type f -exec dos2unix {} + && \
    find /etc/services.d/ -type f -exec dos2unix {} + && \
    find /patch/ -type f -exec dos2unix {} +

RUN apk add --no-cache -U wireguard-tools curl jq patch bash iptables iptables-legacy && \
	patch --verbose -d / -p 0 -i /patch/wg-quick.patch && \
    apk del --purge patch && \
	rm -rf /tmp/* /patch