#!/usr/bin/env bash

EXTRAOPTIONS=${EXTRAOPTIONS:-}
JAVAOPTIONS=${JAVAOPTIONS:-}

if [ -d "/ngrams" ]; then
    EXTRAOPTIONS="${EXTRAOPTIONS} --languageModel /ngrams"
    if [ ! -z ${NGRAM_LANGUAGES+x} ]; then
        bash /ngram.sh "${NGRAM_LANGUAGES}" "/ngrams"
    fi
fi

java ${JAVAOPTIONS} -cp languagetool-server.jar org.languagetool.server.HTTPServer --port 8010 --public --allow-origin '*' ${EXTRAOPTIONS}
