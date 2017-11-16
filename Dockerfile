FROM lambci/lambda:build

ARG ERLANG_VER="20.0"
ARG ELIXIR_VER="1.5.0"

# Install dependencies
RUN yum install -y gcc glibc-devel ncurses-devel autoconf wget unzip zip git-core findutils && yum clean all

ENV ERLANG_DIR=/opt/erlang \
    ELIXIR_DIR=/opt/elixir

# Install Erlang/OTP
RUN wget http://erlang.org/download/otp_src_$ERLANG_VER.tar.gz -O otp_src_$ERLANG_VER.tar.gz \
    && tar -zxf otp_src_$ERLANG_VER.tar.gz -C ~/ && cd ~/otp_src_$ERLANG_VER \
    && sed -i '/#  define EPMD6/c\//#  define EPMD6' ~/otp_src_$ERLANG_VER/erts/epmd/src/epmd_int.h \
    && ./configure --prefix=$ERLANG_DIR && make -j4 && make install \
    && cd && rm -rf ~/otp_src_*

# Install Elixir
RUN wget https://github.com/elixir-lang/elixir/releases/download/v$ELIXIR_VER/Precompiled.zip -O Precompiled.zip \
    && unzip -q Precompiled.zip -d $ELIXIR_DIR && rm -f Precompiled.zip \
    && export PATH=$ERLANG_DIR/bin:$ELIXIR_DIR/bin:$PATH \
    && mix local.hex --force && mix local.rebar --force

ENV PATH="/opt/erlang/bin:${PATH}"
ENV PATH="/opt/elixir/bin:${PATH}"
ENV HOME /home
WORKDIR /home
