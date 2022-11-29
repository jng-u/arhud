xhost +local:docker

docker run --rm -it \
        --volume=/tmp/.X11-unix:/tmp/.X11-unix \
        --volume=/media:/media \
        --device=/dev/dri:/dev/dri \
        --env="DISPLAY=$DISPLAY" \
        --mount type=bind,source=$HOME/dev/ros,target=/home/user/dev/ros \
        --user user \
        --name arhud \
        jngu/ubuntu:arhud

# docker exec -it -u user <name> /bin/zsh