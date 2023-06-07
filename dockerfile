FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive 

RUN apt-get -y update
RUN apt-get -y upgrade

RUN apt install -y curl wget

RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
&& apt-get install -y ./google-chrome-stable_current_amd64.deb \
&& rm -f google-chrome-stable_current_amd64.deb

RUN curl -SL https://deb.nodesource.com/setup_18.x | bash - \
&& apt-get install -y nodejs

# RUN apt install -y npm

RUN npm install -g lighthouse

