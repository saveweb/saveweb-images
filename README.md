# saveweb-images

```bash
sudo docker pull containrrr/watchtower
sudo docker rm -f watchtower \
    && sudo docker run -d \
    -v /var/run/docker.sock:/var/run/docker.sock -v /etc/localtime:/etc/localtime:ro \
    -e 'TZ=Asia/Taipei' \
    -e 'WATCHTOWER_CLEANUP=true' \
    -e 'WATCHTOWER_POLL_INTERVAL=4800' \
    -e 'WATCHTOWER_INCLUDE_STOPPED=true' \
    -e 'WATCHTOWER_REVIVE_STOPPED=true' \
    --name watchtower --restart unless-stopped \
    containrrr/watchtower

export ARCHIVIST=xxx
for _cname in acdanmaku huashijie lowapk-v2; do
    docker pull "icecodexi/saveweb:${_cname}"
    docker rm -f "${_cname}" \
        && docker run --env ARCHIVIST="$ARCHIVIST" --restart always --name "${_cname}" \
            --cpu-shares 512 --memory 512M --memory-swap 512M \
            --detach "icecodexi/saveweb:${_cname}"
done
```
