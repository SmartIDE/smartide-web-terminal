#FROM #{SMARTIDEBASEVERSION}#
FROM registry.cn-hangzhou.aliyuncs.com/smartide/smartide-node-v2:3696

USER root

WORKDIR /home

#安装docker cli
RUN apt-get update
RUN apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update && apt-get install -y docker-ce-cli

#安装kubectl cli
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

#复制terminal文件
COPY ./ webterminal/

#清理无用文件
WORKDIR /home/webterminal
RUN rm -rf .eslintignore .eslintrc.js .git .github .gitignore .ide .npmignore .npmrc \
    Dockerfile LICENSE README.md assets package.json package-lock.json smartide_web_terminal.sh views webshell.gif

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    EDITOR=code \
    VISUAL=code \
    GIT_EDITOR="code --wait" \
    TERMINAL_USER="root" \
    OPENVSCODE_SERVER_ROOT=/home/opvscode

COPY smartide_web_terminal.sh /idesh/smartide_web_terminal.sh
RUN chmod +x /idesh/smartide_web_terminal.sh
EXPOSE 6860

ENTRYPOINT ["/idesh/smartide_web_terminal.sh"]