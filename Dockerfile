FROM ubuntu:16.04
MAINTAINER Vaibhav Bhembre <vaibhav@digitalocean.com>

ENV GOROOT /goroot
ENV GOPATH /go
ENV PATH $GOROOT/bin:$PATH
ENV APPLOC $GOPATH/src/github.com/digitalocean/ceph_exporter

RUN apt-get update && \
    apt-get install -y apt-transport-https build-essential git curl wget

RUN wget -q -O- 'https://download.ceph.com/keys/release.asc' | apt-key add -
RUN echo "deb https://download.ceph.com/debian-luminous xenial main" >> /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y --force-yes librados-dev librbd-dev

RUN export https_proxy=http://10.0.0.1:8087 && \
  mkdir -p /goroot && \
  curl https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz | tar xvzf - -C /goroot --strip-components=1

ADD . $APPLOC
WORKDIR $APPLOC
RUN go get -d && \
    go build -o /bin/ceph_exporter


FROM ubuntu:16.04
MAINTAINER Vaibhav Bhembre <vaibhav@digitalocean.com>

RUN apt-get update && \
    apt-get install -y apt-transport-https curl wget
RUN wget -q -O- 'https://download.ceph.com/keys/release.asc' | apt-key add -
RUN echo "deb https://download.ceph.com/debian-luminous xenial main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --force-yes librados2 librbd1 ceph-common && \
    rm -rf /var/lib/apt/lists/*


COPY /ceph_exporter /bin/ceph_exporter
RUN chmod +x /bin/ceph_exporter

EXPOSE 9100
ENTRYPOINT ["/bin/ceph_exporter"]
