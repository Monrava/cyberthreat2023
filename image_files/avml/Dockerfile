#################################################################################################
FROM nginx:latest
RUN apt-get update && \
       apt-get install -y --no-install-recommends apt-utils && \
       apt-get -y install sudo && \
       apt-get -y install libssl-dev pkg-config && \
       apt-get -y install python3-pip && \
       apt-get -y install procps && \
       apt-get -y install curl && \
       apt-get update

### for apt to be noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN echo "tzdata tzdata/Areas select Europe" > /tmp/preseed.txt; \
    echo "tzdata tzdata/Zones/Europe select Stockholm" >> /tmp/preseed.txt; \
    debconf-set-selections /tmp/preseed.txt && \
    apt-get update && \
    apt-get install -y git golang-go
#########################################################################################################
# AVML
# Install MUSL
RUN sudo apt-get install musl-dev musl-tools musl

# Install rustup
RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- --default-toolchain stable -y && \
    /root/.cargo/bin/rustup update beta && \
    /root/.cargo/bin/rustup update nightly

ENV PATH=/root/.cargo/bin:$PATH

RUN git clone https://github.com/microsoft/avml.git
WORKDIR /avml
#To configure your current shell, run:
#source $HOME/.cargo/env

RUN rustup target add x86_64-unknown-linux-musl
RUN cargo build --release --target x86_64-unknown-linux-musl
#########################################################################################################