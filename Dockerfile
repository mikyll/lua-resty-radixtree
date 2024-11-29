FROM ubuntu:20.04

USER root

ENV DEBIAN_FRONTEND=noninteractive

ENV OPENRESTY_PREFIX="/usr/local/openresty"

# Linux dependencies
RUN apt update
RUN apt install -y cpanminus build-essential libncurses5-dev libreadline-dev libssl-dev perl lua5.1 liblua5.1-0-dev \
    curl wget unzip sudo git nano

COPY . /lua-resty-radixtree
# RUN git clone --recurse-submodules https://github.com/api7/lua-resty-radixtree

WORKDIR /lua-resty-radixtree

RUN curl -fsSL https://raw.githubusercontent.com/apache/apisix/master/utils/linux-install-luarocks.sh | sh

# Linux Before install
RUN cpanm --notest Test::Nginx > build.log 2>&1 || (cat build.log && exit 1)

# Linux install
RUN wget -qO - https://openresty.org/package/pubkey.gpg | sudo apt-key add - \
    && sudo apt-get -y install software-properties-common \
    && sudo add-apt-repository -y "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main" \
    && sudo apt-get update \
    && sudo apt-get install -y openresty \
    && git clone https://github.com/openresty/test-nginx.git test-nginx

ENV PATH="${OPENRESTY_PREFIX}/nginx/sbin:${PATH}"

RUN make compile > build.log 2>&1 || (cat build.log && exit 1) \
    && sudo make deps > build.log 2>&1 || (cat build.log && exit 2)

# docker build --tag 'mikyll/lua-resty-radixtree' .
# docker run --rm -it mikyll/lua-resty-radixtree

# prove -Itest-nginx/lib -I. -r t
