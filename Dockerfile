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
RUN cd /opt && wget -q http://dl.google.com/android/android-sdk_r24.3.3-linux.tgz
RUN cd /opt && tar xzf android-sdk_r24.3.3-linux.tgz
RUN cd /opt && rm -f android-sdk_r24.3.3-linux.tgz

# Setup environment
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:/opt/java/jdk1.7/bin

# Git to pull external repositories of Android app projects
RUN apt-get install -y --no-install-recommends git

# Install SDK components
RUN echo "y" | android update sdk \
                --all \
                --no-ui \
                --filter platform-tools,build-tools-23.0.0,android-23,addon-google_apis-google-23,extra-android-support,extra-android-m2repository,extra-google-m2repository,extra-google-google_play_services,sys-img-armeabi-v7a-addon-google_apis-google-23

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
