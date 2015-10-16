FROM ubuntu:14.04

MAINTAINER Benny <benjamin@andnexus.com>

# Install java7
RUN apt-get install -y software-properties-common && add-apt-repository -y ppa:webupd8team/java && apt-get update
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java7-installer

# Install dependencies
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y --force-yes expect git wget libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 python curl

# Install Android SDK
RUN apt-get update -qq
RUN apt-get install -y --no-install-recommends wget
RUN cd /opt && wget -q http://dl.google.com/android/android-sdk_r24.4-linux.tgz
RUN cd /opt && tar xzf android-sdk_r24.4-linux.tgz
RUN cd /opt && rm -f android-sdk_r24.4-linux.tgz

# Setup environment
ENV ANDROID_HOME /opt/android-sdk-linux
ENV ANDROID_SDK_HOME /opt/android-sdk-linux
ENV ANDROID_AVD_HOME /opt/android-sdk-linux/.android/avd
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:/opt/java/jdk1.7/bin

# Show environment variables
RUN export

# Make sure AVD path exists as otherwise we'll fail to create an SD card
RUN mkdir -p $ANDROID_AVD_HOME

# Avoid emulator assumes HOME as '/'.
ENV HOME /root
ADD wait-for-emulator /usr/local/bin/
RUN chmod +x /usr/local/bin/wait-for-emulator
ADD start-emulator /usr/local/bin/
RUN chmod +x /usr/local/bin/start-emulator

# Some preparation before update
RUN apt-get install -y --no-install-recommends git
RUN chown -R root:root /opt/android-sdk-linux

# All SDK components
RUN android list sdk --extended --no-ui --all

# Install latest android tools and system images
RUN echo "y" | android update sdk --filter tools --no-ui --force
RUN echo "y" | android update sdk --filter platform-tools --no-ui --force
RUN echo "y" | android update sdk --filter platform --no-ui --force
RUN echo "y" | android update sdk --filter extra-android-support --no-ui -a
RUN echo "y" | android update sdk --filter extra-android-m2repository --no-ui -a
RUN echo "y" | android update sdk --filter extra-google-m2repository --no-ui -a
RUN echo "y" | android update sdk --filter extra-google-google_play_services --no-ui -a

RUN echo "y" | android update sdk --filter build-tools-23.0.0 --no-ui -a
RUN echo "y" | android update sdk --filter build-tools-23.0.1 --no-ui -a
RUN echo "y" | android update sdk --filter android-23 --no-ui -a
RUN echo "y" | android update sdk --filter addon-google_apis-google-23 --no-ui -a
RUN echo "y" | android update sdk --filter sys-img-armeabi-v7a-android-23 --no-ui -a
RUN echo "y" | android update sdk --filter sys-img-armeabi-v7a-addon-google_apis-google-23 --no-ui -a

# Available SDK targets
RUN android list targets

# Create emulator
RUN echo "no" | android create avd \
                --force \
                --device "Nexus 5" \
                --name test \
                --target "Google Inc.:Google APIs:23" \
                --abi armeabi-v7a \
                --skin WVGA800 \
                --sdcard 512M \
                --tag google_apis

# GO to workspace
RUN mkdir -p /opt/workspace
WORKDIR /opt/workspace
