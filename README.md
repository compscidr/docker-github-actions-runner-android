# docker-github-actions-runner-android
Based off https://github.com/myoung34/docker-github-actions-runner but adds the
android sdk into the container so we don't need to run the setup-android action
every time from: https://github.com/android-actions/setup-android

The Android SDK requires Java, so the container includes a Temurin JDK as well,
which means you can also skip the setup-java action:
https://github.com/actions/setup-java

To run the container, check out the environment variables from the base image:
https://github.com/myoung34/docker-github-actions-runner#environment-variables

There is also an example docker-compose file which uses .env file to set the
variables.

## Image tags

Images are published to both Docker Hub and GitHub Container Registry (GHCR):
- `compscidr/github-runner-android`
- `ghcr.io/compscidr/github-runner-android`

### Tag scheme

Each image is built with a specific combination of base runner version, JDK
version, and Android SDK level. Tags let you choose how tightly to pin:

| Tag | Example | What it pins | What floats |
|-----|---------|--------------|-------------|
| `latest` | `latest` | Nothing | Runner, JDK, and SDK all track latest |
| `jdk<VERSION>` | `jdk21` | JDK major version | Runner and SDK track latest |
| `<RUNNER>-jdk<JDK>-sdk<SDK>` | `2.332.0-jdk21-sdk36` | Everything | Nothing — fully pinned |

### Which tag should I use?

- **`latest`** — always the newest runner, default JDK, and latest Android SDK.
  Good for staying current, but builds may break if a new SDK introduces
  incompatibilities.
- **`jdk21`** or **`jdk17`** — pin the JDK version but still get runner and SDK
  updates automatically. A good balance for most users.
- **`2.332.0-jdk21-sdk36`** — fully pinned. Use this for reproducible builds
  where you want complete control over when to upgrade. Old pinned tags are
  never overwritten; they remain in the registry from previous builds.

### What's in each image?

Every image includes:
- The [myoung34/github-runner](https://github.com/myoung34/docker-github-actions-runner) base image
- [Temurin JDK](https://adoptium.net/) (the version in the tag)
- Android SDK platform matching the SDK level in the tag (e.g., `sdk36` = `platforms;android-36`)
- Latest Android build-tools and NDK for that SDK level
- Android SDK command-line tools, platform-tools, and cmake

Projects that need additional SDK platforms (e.g., an older `compileSdk`) can
install them at build time:
```yaml
- run: sdkmanager "platforms;android-28"
```

### Currently available JDK versions

The build matrix is defined in [`matrix.json`](matrix.json). Check that file
for the current list of JDK versions and which one is the default.

## Automated updates

Versions are kept up to date automatically:

| Component | Mechanism |
|-----------|-----------|
| Base runner image | [Renovate](https://github.com/renovatebot/renovate) tracks `myoung34/github-runner` Docker tags |
| GitHub Actions versions | Renovate (`config:base`) |
| New JDK major versions | Weekly workflow queries the [Adoptium API](https://api.adoptium.net) and opens a PR |
| Android SDK platform level | Weekly workflow queries `sdkmanager` and opens a PR |
| Android build-tools | Weekly workflow queries `sdkmanager` and opens a PR |
| Android NDK | Weekly workflow queries `sdkmanager` and opens a PR |

## Building locally

```
docker build -f Dockerfile .
```

Build args can be used to customize the image. See the top of the
[`Dockerfile`](Dockerfile) for the current defaults and available args
(`VERSION`, `JAVA_VERSION`, `COMPILE_SDK`, `BUILD_TOOLS`, `NDK_VERSION`,
`SDK_TOOLS`).

Example:
```
docker build --build-arg JAVA_VERSION=17 --build-arg COMPILE_SDK=35 -f Dockerfile .
```

## Inspiration
- https://github.com/kriskda/docker-github-action-android-container (comes with emulator which we don't need)
- https://github.com/jordond/docker-android-github-runner (desire more configurability - re:version of myoung34 container, etc)
