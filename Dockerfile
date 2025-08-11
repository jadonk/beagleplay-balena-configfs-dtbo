FROM ubuntu:jammy-20220531 as kernel-build
ARG OS_VERSION=6.5.2
ARG BALENA_MACHINE_NAME=beagleplay
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
RUN apt-get update && \
    apt-get install -y \
    bison \
    build-essential \
    flex \
    libelf-dev \
    libssl-dev \
    bc \
    wget
WORKDIR /usr/src/app
COPY of-configfs/src src/
COPY of-configfs/include include/
COPY of-configfs/build.sh .
RUN ./build.sh -s $BALENA_MACHINE_NAME -v $OS_VERSION -i src -o out

FROM ubuntu:plucky as dt-build
ARG OS_VERSION=6.5.2
ARG BALENA_MACHINE_NAME=beagleplay
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
RUN apt-get update \
  && apt-get install -y \
    bison \
    build-essential \
    flex \
    libelf-dev \
    libssl-dev \
    bc \
    device-tree-compiler \
    wget \
  && apt-get clean
WORKDIR /usr/src/app
COPY dt/src src/
COPY dt/build.sh .
RUN ./build.sh

FROM debian:bookworm AS run
ARG OS_VERSION=6.5.2
ARG BALENA_MACHINE_NAME=beagleplay
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
RUN apt-get update && apt-get install -y \
  gnupg ca-certificates \
	&& apt-get clean \
	&& echo .
RUN echo "deb [arch=arm64] http://debian.beagle.cc/arm64/ bookworm main" >> /etc/apt/sources.list \
       && apt-key adv --batch --keyserver keyserver.ubuntu.com --recv-key D284E608A4C46402
RUN apt-get update \
  && echo .
COPY --from=kernel-build /usr/src/app/out/src_"$BALENA_MACHINE_NAME"_"$OS_VERSION" /opt/lib/modules
COPY --from=dt-build /usr/src/app/out /opt/lib/dt
WORKDIR /usr/src/app
COPY . /usr/src/app
CMD ["bash", "start.sh"]

