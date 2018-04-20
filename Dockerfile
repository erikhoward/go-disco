# DESCRIPTION:	Go 1.9 Machine Learning development container
# AUTHOR:	Erik Howard <erikhoward@protonmail.com>
# COMMENT:	A Golang 1.9 machine learning development docker container
#
# USAGE:
#	Interactive terminal
#	docker run --rm -it --name godisco -v $HOME/go/src:/go/src 

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
