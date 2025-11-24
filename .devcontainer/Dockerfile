FROM python:3.13-bullseye

RUN curl -sL https://deb.nodesource.com/setup_20.x | bash

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive && \
    apt-get -y install nodejs nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/list/*

CMD ["nginx", "-g", "daemon off;"]