FROM ubuntu:22.04

COPY ./ /src/

RUN DEBIAN_FRONTEND=noninteractive apt-get --yes update \
        && apt-get --yes install python3 python3-venv python3-pip --no-install-recommends \
        && rm -Rf /var/cache/apt \
        && rm -Rf /var/lib/apt/lists/* \
        && rm -Rf /var/log/* \
        && rm -Rf /tmp/*

RUN pip install awslambdaric

RUN adduser --disabled-login --gecos "" hello
ENV AWS_DEFAULT_REGION us-east-2
USER hello
WORKDIR /src
ENV LC_ALL="C.UTF-8" LANG="C.UTF-8"

ENTRYPOINT ["/usr/bin/python3","/src/hello.py"]

