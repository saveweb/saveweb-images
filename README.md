# saveweb-images

该镜像仓库维护所有 saveweb 开发的数据抓取程序的容器镜像，这些镜像不占用 CPU、内存、存储资源，只需要网络就可运行  
镜像的维护遵循社区最佳实践，容器内都主动使用非 root 账户执行。构建过程也完全公开，请放心使用  

## 注意事项
* 不可在相同 IP 下创建同一抓取程序的多个实例（如 huashijie-1, huashijie-2）。不同抓取程序可共存（如 huashijie, acdanmaku）
* 执行下面的启动命令前，请为自己选择一个可以用来识别自己贡献的贡献者 ID。如 `export ARCHIVIST=icn`

## 如何使用
0. （可选）推荐部署 watchtower 容器实现容器镜像自动更新
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
```

1. 部署所有 saveweb worker 容器

```bash
if [[ -z "$ARCHIVIST" ]]; then
    echo "WARN: ARCHIVIST must be set"
    exit 1
fi
for _cname in acdanmaku huashijie lowapk-v2; do
    _image="icecodexi/saveweb:${_cname}"
    docker pull "${_image}" \
        && docker stop "${_cname}"
    docker rm -f "${_cname}" \
        && docker run --env ARCHIVIST="$ARCHIVIST" --restart always \
            --volume /etc/localtime:/etc/localtime:ro \
            --cpu-shares 512 --memory 512M --memory-swap 512M \
            --detach  --name "${_cname}" \
            "${_image}"
done
```
