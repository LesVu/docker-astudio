#!/bin/bash

# docker build . -f Dockerfile --no-cache --build-arg="user=abc" --tag lesvu/vn_vnc:latest
docker build . -f Dockerfile --build-arg="user=abc" --tag lesvu/android-studio:latest
# docker push lesvu/vn_vnc:latest
