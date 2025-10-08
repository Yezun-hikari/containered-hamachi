# Base image for ARMv7 architecture
FROM balenalib/armv7hf-debian:latest

# Install dependencies needed for download and installation
RUN apt-get update && \
    apt-get install -y lsb-release wget && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV HAMACHI_URL=https://vpn.net/installers/logmein-hamachi-2.1.0.203-armel.tgz
ENV HAMACHI_TGZ=logmein-hamachi.tgz
ENV HAMACHI_DIR=logmein-hamachi-2.1.0.203-armel
ENV HAMACHI_DST=/opt/logmein-hamachi

# Download, extract, and install Hamachi
RUN wget -q -O "$HAMACHI_TGZ" "$HAMACHI_URL" && \
    tar -xzvf "$HAMACHI_TGZ" && \
    mkdir -p "$HAMACHI_DST/bin" && \
    install -m 755 "$HAMACHI_DIR/hamachid" "$HAMACHI_DST/bin" && \
    install -m 755 "$HAMACHI_DIR/dnsup" "$HAMACHI_DST/bin" && \
    install -m 755 "$HAMACHI_DIR/dnsdown" "$HAMACHI_DST/bin" && \
    install -m 755 "$HAMACHI_DIR/uninstall.sh" "$HAMACHI_DST" && \
    ln -sf "$HAMACHI_DST/bin/hamachid" /usr/bin/hamachi && \
    # Create TunTap device (Docker host should provide it, but this is for completeness)
    if [ ! -c /dev/net/tun ]; then \
        mkdir -p /dev/net && \
        mknod /dev/net/tun c 10 200 && \
        chmod 0666 /dev/net/tun; \
    fi && \
    # Clean up downloaded and extracted files
    rm -rf "$HAMACHI_TGZ" "$HAMACHI_DIR"

# Copy the start script, which will be created in the repository.
# In a real-world git repo, this file would be present.
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Set the entrypoint
ENTRYPOINT ["/start.sh"]