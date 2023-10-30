#################################################################################
#Install depedencies
#################################################################################
#!/bin/bash
sudo apt-get update
#wait 30
sudo apt-get install -yq build-essential python3-pip rsync python3-dev libffi-dev gcc libc-dev cargo make musl-dev musl-tools musl curl git golang-1.14
#apt-get update && \
    #    apt-get install -y --no-install-recommends apt-utils && \
    #    apt-get -y install sudo && \
    #    apt-get -y install libssl-dev pkg-config && \
    #    apt-get -y install python3-pip && \
    #    apt-get -y install procps && \
    #    apt-get update
#wait 30
# Install MUSL
sudo apt-get install -yq musl-dev musl-tools musl

# Set installation directory
cd $HOME

# Install Rust via rustup
#curl https://sh.rustup.rs -sSf | sh -s -- -y
sudo curl https://sh.rustup.rs -sSf | \
    sh -s -- --default-toolchain stable -y 

# Update the env 
source "$HOME/.cargo/env"

# Finalize rustup config 
sudo /root/.cargo/bin/rustup update beta 
sudo /root/.cargo/bin/rustup update nightly

# Clone AVML
cd $HOME
git clone https://github.com/microsoft/avml.git 
cd avml
rustup target add x86_64-unknown-linux-musl
cargo build --release --target x86_64-unknown-linux-musl

# Install dwarf2json
# go version - https://ubuntu.pkgs.org/20.04/ubuntu-main-amd64/golang-1.14_1.14.2-1ubuntu1_all.deb.html
cd $HOME
git clone https://github.com/volatilityfoundation/dwarf2json.git
cd dwarf2json
# Install using the required go version
/usr/lib/go-1.14/bin/go build 
cd $HOME

# Install volatility3
git clone https://github.com/volatilityfoundation/volatility3.git
cd volatility3
pip3 install -r requirements.txt
python3 setup.py build
#sudo python3 setup.py install
cd $HOME