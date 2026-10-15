#!/bin/bash

# Run Docker container
docker run -d --name dell-drm --tmpfs /tmp -p 8090:8091 dell-drm:3.5.3

# Wait DRM startup then open web browser
echo Wait about 30 seconds then open https://localhost:8090/drm/ ...
sleep 30
open https://localhost:8090/drm/ &
