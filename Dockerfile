ARG VERSION=2.294.0-ubuntu-focal
ARG JAVA_VERSION=17
ARG SDK_TOOLS=8512546_latest
ARG ANDROID_ROOT=/usr/local/lib/android

################################################################################
# base image from https://github.com/myoung34/docker-github-actions-runner
# - install temurin java into it
################################################################################
FROM myoung34/github-runner:$VERSION as java
ARG JAVA_VERSION

# https://adoptium.net/installation/linux
# add the gpp key and apt repo
RUN mkdir -p /etc/apt/keyrings && \
  wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc && \
  echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list

# install the temurin jdk
RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends temurin-$JAVA_VERSION-jdk

################################################################################
# - install android sdk
################################################################################
FROM java as android
ARG SDK_TOOLS
ARG ANDROID_ROOT

WORKDIR /tmp

# download android tools and use it to install the SDK
RUN mkdir -p ${ANDROID_ROOT}/sdk/cmdline-tools/latest
RUN wget -O android-sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-$SDK_TOOLS.zip && unzip android-sdk.zip && cp -r ./cmdline-tools/* ${ANDROID_ROOT}/sdk/cmdline-tools/latest
RUN ${ANDROID_ROOT}/sdk/cmdline-tools/latest/bin/sdkmanager --licenses >/dev/null

# You can check Android Studio -> Appearance & Behavior -> System Settings -> Android SDK -> SDK Tools
# for the various possibilites here. This is also a good list:
# https://gist.github.com/alvr/8db356880447d2c4bbe948ea92d22c23
# We can reduce the image size by supporting fewer versions here if we want.
RUN echo "y" | ${ANDROID_ROOT}/sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_ROOT/sdk/ \
  "platform-tools" \
  "platforms;android-33" \
  "platforms;android-32" \
  "platforms;android-31" \
  "platforms;android-30" \
  "platforms;android-29" \
  "platforms;android-28" \
  "platforms;android-21" \
  "build-tools;33.0.0" \
  "build-tools;32.0.0" \
  "build-tools;31.0.0" \
  "build-tools;30.0.3" \
  "build-tools;30.0.2" \
  "build-tools;30.0.1" \
  "build-tools;30.0.0" \
  "build-tools;29.0.3" \
  "build-tools;29.0.2" \
  "build-tools;29.0.0" \
  "build-tools;28.0.3" \
  "extras;android;m2repository" \
  "extras;google;m2repository" \
  "extras;google;google_play_services" \
  "add-ons;addon-google_apis-google-24" \
  "add-ons;addon-google_apis-google-23" \
  "add-ons;addon-google_apis-google-22" \
  "add-ons;addon-google_apis-google-21" 1>/dev/null

WORKDIR /actions-runner
ENV PATH="${PATH}:/usr/local/lib/android/sdk/platform-tools/"

# Set env variable for SDK Root (https://developer.android.com/studio/command-line/variables)
# ANDROID_HOME is deprecated, but older versions of Gradle rely on it
ENV ANDROID_SDK_ROOT=$ANDROID_ROOT/sdk
ENV ANDROID_HOME=$ANDROID_ROOT/sdk
LABEL maintainer="ernstjason1@gmail.com"

# NB: there is no CMD so it will work the same as the base image. See the
# https://github.com/myoung34/docker-github-actions-runner#environment-variables
# for how to use the image
