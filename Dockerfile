DockerfileFROM openjdk:21-jdk-slim

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
	apt-get install -y --no-install-recommends \
	bzip2 \
	ca-certificates \
	curl \
	iproute2 \
	libasound2 \
	libdbus-glib-1-2 \
	libdrm2 \
	libgbm1 \
	libgl1 \
	libglu1-mesa \
	libnss3 \
	libpulse0 \
	libx11-6 \
	libx11-xcb1 \
	libxcomposite1 \
	libxcursor1 \
	libxi6 \
	libxkbcommon0 \
	libxrandr2 \
	libxrender1 \
	libxshmfence1 \
	libxtst6 \
	socat \
	unzip \
	wget \
	xauth \
	xvfb && \
	rm -rf /var/lib/apt/lists/*


# Docker labels.
LABEL maintainer "Halim Qarroum <hqm.post@gmail.com>"
LABEL description "A Docker image allowing to run an Android emulator"
LABEL version "1.3.0"


# Arguments that can be overriden at build-time.
ARG INSTALL_ANDROID_SDK=1
ARG API_LEVEL=34
ARG IMG_TYPE=google_apis
ARG ARCHITECTURE=x86_64
ARG CMD_LINE_VERSION=11076708_latest
ARG DEVICE_ID=pixel
ARG GPU_ACCELERATED=false

# Environment variables.
ENV ANDROID_SDK_ROOT=/opt/android \
	ANDROID_HOME=/opt/android \
	ANDROID_PLATFORM_VERSION="platforms;android-$API_LEVEL" \
	PACKAGE_PATH="system-images;android-${API_LEVEL};${IMG_TYPE};${ARCHITECTURE}" \
	API_LEVEL=$API_LEVEL \
	DEVICE_ID=$DEVICE_ID \
	ARCHITECTURE=$ARCHITECTURE \
	ABI=${IMG_TYPE}/${ARCHITECTURE} \
	GPU_ACCELERATED=$GPU_ACCELERATED \
	QTWEBENGINE_DISABLE_SANDBOX=1 \
	ANDROID_EMULATOR_WAIT_TIME_BEFORE_KILL=10 \
	ANDROID_AVD_HOME=/data

# Exporting environment variables to keep in the path
# Android SDK binaries and shared libraries.
ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/emulator:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin
ENV LD_LIBRARY_PATH=${ANDROID_SDK_ROOT}/emulator/lib64:${ANDROID_SDK_ROOT}/emulator/lib64/qt/lib

# Set the working directory to /opt
WORKDIR /opt

# Exposing the Android emulator console port
# and the ADB port.
EXPOSE 5554 5555

# Initializing the required directories.
RUN mkdir /root/.android/ && \
	touch /root/.android/repositories.cfg && \
	mkdir /data

# Exporting ADB keys.
COPY keys/* /root/.android/

# The following layers will download the Android command-line tools
# to install the Android SDK, emulator and system images.
# It will then install the Android SDK and emulator.
COPY scripts/install-sdk.sh /opt/
RUN chmod +x /opt/install-sdk.sh
RUN /opt/install-sdk.sh

# Copy the container scripts in the image.
COPY scripts/start-emulator.sh /opt/
COPY scripts/emulator-monitoring.sh /opt/
RUN chmod +x /opt/*.sh

# Set the entrypoint
ENTRYPOINT ["/opt/start-emulator.sh"]
