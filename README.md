# docker-github-actions-runner-android
Based off https://github.com/myoung34/docker-github-actions-runner but adds the
android sdk into the container so we don't need to run the setup-android action
every time from: https://github.com/android-actions/setup-android

NB: android sdk requires java to be installed, so the container will also have
this installed too, which means we can also avoid running the setup-java action
in workflows: https://github.com/actions/setup-java

This will have the downside that github actions java version matrices may not
work well, will need to look into that more.

To run the container, check out the environment variables from the base image:
https://github.com/myoung34/docker-github-actions-runner#environment-variables

## Building:
`docker build -f Dockerfile .`

There are several build args:
```
ARG VERSION=2.294.0-ubuntu-focal
ARG JAVA_VERSION=11
ARG SDK_TOOLS=8512546_latest
ARG ANDROID_ROOT=/usr/local/lib/android
```

which can be set as follows:
`docker build --build-arg VERSION=<some version> --build-arg JAVA_VERSION=<some java version> -f Dockerfile .`

## inspiration:
- https://github.com/kriskda/docker-github-action-android-container (comes with emulator which we don't need)
- https://github.com/jordond/docker-android-github-runner (desire more configurability - re:version of myoung34 container, etc)
