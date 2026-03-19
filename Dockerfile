ARG VERSION=2.333.0-ubuntu-noble
ARG JAVA_VERSION=21
ARG COMPILE_SDK=36
ARG BUILD_TOOLS=37.0.0
ARG NDK_VERSION=29.0.14206865
ARG SDK_TOOLS=8512546_latest
ARG ANDROID_ROOT=/usr/local/lib/android

################################################################################
# base image from https://github.com/myoung34/docker-github-actions-runner
# - install temurin java into it
################################################################################
FROM myoung34/github-runner:$VERSION AS java
ARG JAVA_VERSION

# https://adoptium.net/installation/linux
# add the gpp key and apt repo
RUN mkdir -p /etc/apt/keyrings && \
  wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc && \
  echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list

# install the temurin jdk
RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends temurin-$JAVA_VERSION-jdk
ENV JAVA_HOME=/usr/lib/jvm/temurin-$JAVA_VERSION-jdk-amd64

# install ip tools
RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends iproute2

# install cmake build-essential
RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends cmake build-essential swig

################################################################################
# - install android sdk
################################################################################
FROM java AS android
ARG COMPILE_SDK
ARG BUILD_TOOLS
ARG NDK_VERSION
ARG SDK_TOOLS
ARG ANDROID_ROOT

WORKDIR /tmp

# download android tools and use it to install the SDK
RUN mkdir -p ${ANDROID_ROOT}/sdk/cmdline-tools/latest
RUN wget -O android-sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-$SDK_TOOLS.zip && unzip android-sdk.zip && cp -r ./cmdline-tools/* ${ANDROID_ROOT}/sdk/cmdline-tools/latest
RUN ${ANDROID_ROOT}/sdk/cmdline-tools/latest/bin/sdkmanager --licenses >/dev/null

# Install latest Android SDK components only. Older versions are not needed since
# build-tools and NDK are backward compatible, and you only need the platform
# matching your project's compileSdk. Projects needing older platforms can install
# them at build time via sdkmanager.
RUN echo "y" | ${ANDROID_ROOT}/sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_ROOT/sdk/ \
  "platform-tools" \
  "platforms;android-${COMPILE_SDK}" \
  "build-tools;${BUILD_TOOLS}" \
  "ndk;${NDK_VERSION}" \
  "cmake;3.22.1"

WORKDIR /actions-runner
ENV PATH="${PATH}:/usr/local/lib/android/sdk/platform-tools/"

# Set env variable for SDK Root (https://developer.android.com/studio/command-line/variables)
# ANDROID_HOME is deprecated, but older versions of Gradle rely on it
ENV ANDROID_SDK_ROOT=$ANDROID_ROOT/sdk
ENV ANDROID_HOME=$ANDROID_ROOT/sdk
LABEL maintainer="ernstjason1@gmail.com"

# Post-job cleanup hook to prevent unbounded cache growth
COPY cleanup.sh /usr/local/bin/cleanup.sh
RUN chmod +x /usr/local/bin/cleanup.sh
ENV ACTIONS_RUNNER_HOOK_JOB_COMPLETED=/usr/local/bin/cleanup.sh

# NB: there is no CMD so it will work the same as the base image. See the
# https://github.com/myoung34/docker-github-actions-runner#environment-variables
# for how to use the image
