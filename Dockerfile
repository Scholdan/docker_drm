FROM ubuntu:26.04

# DRM website: https://www.dell.com/support/home/en-us/drivers/driversdetails?driverId=CD41F

# Install needed tools, clean up, download and install DRM, clean up
RUN apt-get update && \
    apt-get install -y wget socat file && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    wget -U drm -O drm.bin https://downloads.dell.com/FOLDER15051603M/1/DRMInstaller_3.5.3.152.bin && \
    echo "29e7123c6fcb3cd5b5f19dc0c48bdfe1f23f3cb2cf17a131120d52f9009b7e8c  drm.bin" | sha256sum -c - && \
    sh drm.bin -i silent && \
    rm -rf /tmp/*

# DRM 3.5.x adds a FilterController that requires a Basic-auth credential only
# its bundled desktop client knows, so the web UI returns 401 to a plain browser.
# This is a single-user tool on localhost, so drop that filter mapping to make
# the UI reachable over socat as it was on 3.4.x.
RUN perl -0pi -e 's{\s*<filter-mapping>\s*<filter-name>FilterController</filter-name>.*?</filter-mapping>}{}s' \
    /opt/dell/dellrepositorymanager/web/WEB-INF/web.xml

# Run socat and DRM as unprivileged user
USER drmuser

# Create a volume to hold the downloaded objects
VOLUME ["/var/dell/drm/"]

# Expose port forwarded from socat
EXPOSE 8091

# Install start script
COPY start.sh /opt/dell/dellrepositorymanager/

# Start script to run DRM and socat
CMD ["/opt/dell/dellrepositorymanager/start.sh"]
