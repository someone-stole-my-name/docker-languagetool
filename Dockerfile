FROM openjdk:slim

ARG VERSION=5.7

RUN apt-get update && \
    apt-get install -y \
        curl \
        libarchive-tools && \
    rm -rf /var/lib/apt/lists/*

RUN curl --progress-bar "https://languagetool.org/download/LanguageTool-$VERSION.zip" |\
    bsdtar -x -f -

RUN adduser \
  --home /LanguageTool-$VERSION \
  --no-create-home languagetool

ADD --chown=languagetool misc/init.sh /
ADD --chown=languagetool misc/ngram.sh /

WORKDIR /LanguageTool-$VERSION
HEALTHCHECK --timeout=10s --start-period=5s \
  CMD curl --fail --data "language=en-US&text=healthcheck test" http://localhost:8010/v2/check || exit 1
CMD [ "bash", "/init.sh" ]
USER languagetool
EXPOSE 8010
