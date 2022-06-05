#FROM #{SMARTIDEBASEVERSION}#
FROM registry.cn-hangzhou.aliyuncs.com/smartide/smartide-node-v2:3696

USER root

WORKDIR /home
#复制IDE文件
COPY ../build webterminal

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    EDITOR=code \
    VISUAL=code \
    GIT_EDITOR="code --wait" \
    OPENVSCODE_SERVER_ROOT=/home/opvscode

COPY gosu_entrypoint_node.sh /idesh/gosu_entrypoint_node.sh
RUN chmod +x /idesh/gosu_entrypoint_node.sh