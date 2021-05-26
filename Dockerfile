FROM debian:stretch


RUN apt update -y && apt upgrade -y && apt install -y build-essential screen netcat cmake wget gdb htop vim git libssl-dev libffi-dev tmux gdbserver gdb-multiarch zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev curl libbz2-dev python3 python3-dev python3-pip python3-setuptools && rm -rf /var/lib/apt/lists/*

RUN curl -O https://www.python.org/ftp/python/3.9.5/Python-3.9.5.tar.xz
RUN tar -xf Python-3.9.5.tar.xz
RUN cd Python-3.9.5 \
    && ./configure --enable-optimizations \
    && make -j 12 \
    && make altinstall


# Locales setup
RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" \
    && apt-get install -y \
        locales \
        tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
    ENV LANG en_US.UTF-8  
    ENV LANGUAGE en_US:en  
    ENV LC_ALL en_US.UTF-8   

RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install --upgrade ipython

RUN python3 -m pip install --upgrade ropper \
    && DSTDIR=/opt \
    && cd ${DSTDIR} \
    && git clone https://github.com/pwndbg/pwndbg \
    && cd pwndbg \
    && ./setup.sh

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
RUN python3.9 -m pip install --upgrade pip \
    && python3.9 -m pip install --upgrade pwntools

RUN echo "export LC_ALL=en_US.UTF-8" >> ~/.bashrc
RUN echo "export PYTHONIOENCODING=UTF-8" >> ~/.bashrc

# Angr for symbolic execution
RUN python3.9 -m pip install --upgrade angr

ADD https://yx7.cc/code/ynetd/ynetd-0.1.2.tar.xz /ynetd-0.1.2.tar.xz

RUN tar -xf ynetd-0.1.2.tar.xz

RUN make -C /ynetd-0.1.2/

RUN useradd -m pwn

#ADD vuln /home/pwn/vuln
ADD start_server.sh /usr/local/bin/
ADD init.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start_server.sh
RUN chmod +x /usr/local/bin/init.sh

#RUN chmod 0755 /home/pwn/vuln

EXPOSE 1337

WORKDIR /home/pwn/

CMD ["/usr/local/bin/init.sh"]
