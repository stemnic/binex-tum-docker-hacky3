FROM debian:stretch

RUN apt update -y && apt upgrade -y && apt install -y screen netcat build-essential cmake wget gdb htop vim git python3 python3-pip python3-dev libssl-dev libffi-dev tmux gdbserver gdb-multiarch && rm -rf /var/lib/apt/lists/*

# Locales setup
RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" \
    && apt-get install -y \
        locales \
        tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8

RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install --upgrade ipython

RUN python3 -m pip install --upgrade ropper \
    && DSTDIR=/opt \
    && cd ${DSTDIR} \
    && git clone https://github.com/pwndbg/pwndbg \
    && cd pwndbg && ./setup.sh

# Peda (default disabled)
RUN DSTDIR=/opt \
    && cd ${DSTDIR} \
    && git clone https://github.com/longld/peda.git ${DSTDIR}/peda \
    && echo "# source ${DSTDIR}/peda/peda.py" >> ~/.gdbinit

# Gef (default disabled)
RUN python3 -m pip install --upgrade keystone-engine \
    && DSTDIR=/opt \
    && mkdir -p ${DSTDIR}/gef \
    && wget -O "${DSTDIR}/gef/gdbinit-gef.py" -q "https://github.com/hugsy/gef/raw/master/gef.py" \
    && echo "# source ${DSTDIR}/gef/gdbinit-gef.py" >> ~/.gdbinit

# Pwntools
RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install --upgrade pwntools

RUN echo "LC_ALL=en_US.UTF-8 PYTHONIOENCODING=UTF-8 gdb" >> ~/.bashrc

# Angr for symbolic execution
RUN python3 -m pip install --upgrade angr

ADD https://yx7.cc/code/ynetd/ynetd-0.1.2.tar.xz /ynetd-0.1.2.tar.xz

RUN tar -xf ynetd-0.1.2.tar.xz

RUN make -C /ynetd-0.1.2/

RUN useradd -m pwn

#ADD vuln /home/pwn/vuln
ADD start_server.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start_server.sh

#RUN chmod 0755 /home/pwn/vuln

EXPOSE 1337

WORKDIR /home/pwn/

CMD ["bash"]
