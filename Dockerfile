FROM openjdk:slim

ARG VERSION=5.7

RUN apt-get update && \
    apt-get install -y \
        curl \
        libarchive-tools && \
    rm -rf /var/lib/apt/lists/*

RUN curl --progress-bar "https://languagetool.org/download/LanguageTool-$VERSION.zip" |\
    bsdtar -x -f -

ADD misc/init.sh /init.sh
ADD misc/ngram.sh /ngram.sh

WORKDIR /LanguageTool-$VERSION
CMD [ "sh", "/init.sh" ]
USER nobody
EXPOSE 8010
