#!/usr/bin/env bash

EXTRAOPTIONS=${EXTRAOPTIONS:-}
JAVAOPTIONS=${JAVAOPTIONS:-}

if [ -d "/ngrams" ]; then
    EXTRAOPTIONS="${EXTRAOPTIONS} --languageModel /ngrams"
    if [ ! -z ${NGRAM_LANGUAGES+x} ]; then
        bash /ngram.sh "${NGRAM_LANGUAGES}" "/ngrams"
    fi
fi

for var in ${!LT_*}; do
  EXTRA_LT=true
  echo "${var#'LT_'}="${!var} >> /tmp/config.properties
done

echo JAVAOPTIONS=$JAVAOPTIONS
if [ "$EXTRA_LT" = true ]; then
  EXTRAOPTIONS="${EXTRAOPTIONS} --config /tmp/config.properties"
    echo config.properties:
    echo "$(cat /tmp/config.properties)"
fi
echo EXTRAOPTIONS=$EXTRAOPTIONS

java ${JAVAOPTIONS} -cp languagetool-server.jar org.languagetool.server.HTTPServer --port 8010 --public --allow-origin '*' ${EXTRAOPTIONS}
