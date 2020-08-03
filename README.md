# thrx-docker-fritzbox-ntopng

## WIP: CURRENTLY NOT WORKING

## Ref:
https://github.com/thbe/docker-ntopng


### Run docker instance ###
docker run --detach --restart always \
  --cap-add=SYS_ADMIN -e "container=docker" \
  -e ENV_HOST="$(hostname -f)" \
  -e FRITZUSER="username" \
  -e FRITZPWD="pwd" \
  -e IFACE="pwd" \
  --name ntopng --hostname ntopng.$(hostname -f | sed -e 's/^[^.]*\.//') \
  -p 3000:3000/tcp \
  thrx/thrx-fritzbox-ntopng

---------------------

docker run \
    --name ntopng-fritz \
    --cap-add=SYS_ADMIN \
    -e "container=docker" \
    -e ENV_HOST="$(hostname -f)" \
    -e FRITZUSER="capture" \
    -e FRITZPWD="captureAdmin4EveryOne" \
    -e IFACE="1-wan" \
    --hostname ntopng.$(hostname -f | sed -e 's/^[^.]*.//') \
    -p 3000:3000/tcp thrx-fritzbox-ntopng


-------------
docker build . --tag thrx-fritzbox-ntopng
docker run     --name ntopng-fritz     --cap-add=SYS_ADMIN     -e "container=docker"     -e ENV_HOST="$(hostname -f)"     -e FRITZUSER="capture"     -e FRITZPWD="captureAdmin4EveryOne"     -e IFACE="1-wan"     --hostname ntopng.$(hostname -f | sed -e 's/^[^.]*.//')     -p 3000:3000/tcp thrx-fritzbox-ntopng

