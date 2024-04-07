# Thing need to run

2. port `5900`
3. Init

```
--privileged -p 5900:5900 -p 4713:4713 --init --dns 1.1.1.1 --dns 1.0.0.1 --shm-size=256mb --device /dev/dri --cap-add=SYS_ADMIN
```
