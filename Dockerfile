# DESCRIPTION:	Go 1.9 Machine Learning development container
# AUTHOR:	Erik Howard <erikhoward@protonmail.com>
# COMMENT:	A Golang 1.9 machine learning development docker container
#
# USAGE:
#	Interactive terminal
#	docker run --rm -it --name godisco -v $PWD:/go/src erikhoward/go-disco /bin/bash
#
#	Go Jupyter notebook
#	docker run --rm -it -p 8888:8888 erikhoward/go-disco jupyter notebook --ip=0.0.0.0 --allow-root

# Base docker image
FROM debian:jessie-slim

LABEL maintainer "Erik Howard <erikhoward@protonmail.com>"

ARG GOLANG_VERSION=1.9.5

RUN apt-get update -y && apt-get install -y \
    curl \
    git \
    mercurial \
    g++ \
    gcc \
    libc6-dev \
    make \
    nano \
    pkg-config \
    locales \
    openssl \
    libzmq3-dev \
    python3-pip \
    python3-dev \
    unzip \
    wget \
    build-essential \
    ca-certificates \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Ensure UTF-8 locale
COPY locale /etc/default/locale
RUN locale-gen en_US.UTF-8 && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

# Download and install Go
RUN wget -O go.tgz https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go.tgz && \
    rm go.tgz

# Setup Go env and paths
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "${GOPATH}/src" "${GOPATH}/bin" && \
    chmod -R 777 "${GOPATH}"

WORKDIR $GOPATH

# Install gocv
# Currently broken for Debian-based distros: https://github.com/hybridgroup/gocv/issues/162
# RUN go get -u -d gocv.io/x/gocv && cd $GOPATH/src/gocv.io/x/gocv && \
#    make deps && make download && make build && make clean && \
#    cd $GOPATH/src/gocv.io/x/gocv && source ./env.sh && \
#    go install gocv.io/x/gocv

# Install machine learning Go libs
RUN go get github.com/kniren/gota/dataframe && \
    go get github.com/kniren/gota/series && \
    go get github.com/sajari/regression && \
    go get go-hep.org/x/hep/fit && \
    go get github.com/berkmancenter/ridge && \
    go get github.com/xlvector/hector &&  \
    go get github.com/cdipaolo/goml/base && \
    go get github.com/cdipaolo/goml/cluster && \
    go get github.com/cdipaolo/goml/linear && \
    go get github.com/cdipaolo/goml/perceptron && \
    go get github.com/cdipaolo/goml/text && \
    go get github.com/sjwhitworth/golearn && \
    go get github.com/rikonor/go-ann && \
    go get github.com/akreal/knn && \
    go get github.com/ryanbressler/CloudForest && \
    go get gonum.org/v1/gonum/... && \
    go get github.com/mash/gokmeans && \
    go get github.com/gorgonia/gorgonia

# Install Tensorflow
ARG TF_TYPE="cpu"
ARG TARGET_DIRECTORY='/usr/local'

RUN curl -L \
    "https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-${TF_TYPE}-$(go env GOOS)-x86_64-1.7.0.tar.gz" | \
    tar -C $TARGET_DIRECTORY -xz && \
    ldconfig && \
    go get github.com/tensorflow/tensorflow/tensorflow/go

# Install lgo - Go Jupyter notebooks
# https://github.com/yunabe/lgo

# Install Jupyter notebook
RUN pip3 install -U pip && \
    pip3 install -vU setuptools && \
    pip3 install -U jupyter jupyterlab && \
    jupyter serverextension enable --py jupyterlab --sys-prefix

# Support UTF-8 filename in Python (https://stackoverflow.com/a/31754469)
ENV LC_CTYPE=C.UTF-8

ENV LGOPATH /lgo
RUN mkdir -p $LGOPATH

# Add a non-root user with uid:1000 to follow the convention of mybinder to use this image from mybinder.org.
# https://mybinder.readthedocs.io/en/latest/dockerfile.html
ARG NB_USER=disco
ARG NB_UID=1000
ENV HOME /home/${NB_USER}
RUN adduser --disabled-password \
    --gecos "Disco user" \
    --uid ${NB_UID} \
    --home ${HOME} \
    ${NB_USER}

RUN mkdir -p ${HOME}/go/src ${HOME}/notebooks && \
    chown -R ${NB_USER}:${NB_USER} ${HOME} $GOPATH $LGOPATH ${HOME}/notebooks
USER ${NB_USER}
WORKDIR ${HOME}

# Fetch lgo repository
RUN go get github.com/yunabe/lgo/cmd/lgo && go get -d github.com/yunabe/lgo/cmd/lgo-internal

# Install packages used from example notebooks.
RUN go get -u github.com/nfnt/resize gonum.org/v1/gonum/... gonum.org/v1/plot/... github.com/wcharczuk/go-chart

# Install lgo
RUN lgo install && lgo installpkg github.com/nfnt/resize gonum.org/v1/gonum/... gonum.org/v1/plot/... github.com/wcharczuk/go-chart
RUN lgo installpkg github.com/tensorflow/tensorflow/tensorflow/go github.com/tensorflow/tensorflow/tensorflow/go/op
RUN python3 $GOPATH/src/github.com/yunabe/lgo/bin/install_kernel
