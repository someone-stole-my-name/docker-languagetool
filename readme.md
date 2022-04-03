[![Publish](https://github.com/someone-stole-my-name/docker-languagetool/actions/workflows/main.yml/badge.svg?branch=master)](https://github.com/someone-stole-my-name/docker-languagetool/actions/workflows/main.yml) [![Test](https://github.com/someone-stole-my-name/docker-languagetool/actions/workflows/test.yml/badge.svg)](https://github.com/someone-stole-my-name/docker-languagetool/actions/workflows/test.yml) [![trivy](https://github.com/someone-stole-my-name/docker-languagetool/actions/workflows/trivy.yml/badge.svg?branch=master)](https://github.com/someone-stole-my-name/docker-languagetool/actions/workflows/trivy.yml)

# Introduction

[LanguageTool] is an Open Source proof­reading software for English, French,
German, Polish, and more than 20 other languages.

You can use LanguageTool with a [Firefox extension].

This is a container to get the LanguageTool running on a system without java.

[LanguageTool]: https://www.languagetool.org/
[Firefox extension]: https://addons.mozilla.org/firefox/addon/languagetool

# Usage

The Server is running on port 8010, this port should exposed.

    docker pull ghcr.io/someone-stole-my-name/docker-languagetool
    [...]
    docker run --rm -p 8010:8010 ghcr.io/someone-stole-my-name/docker-languagetool

Or you run it in background via `-d` option.

Run with minimum rights and RAM limit

    docker run --name languagetool \
        --cap-drop=ALL \
        --user=65534:65534 \
        --read-only \
        --mount type=bind,src=/tmp/languagetool/tmp,dst=/tmp \
        -p 127.0.0.1:8010:8010 \
        --memory 412m --memory-swap 500m \
        -e JAVAOPTIONS="-Xmx382M" \
        ghcr.io/someone-stole-my-name/docker-languagetool:latest


Route information can be found at https://languagetool.org/http-api/swagger-ui/#/default, an easy route to test that it's running is `/v2/languages`.

## ngram support

To support [ngrams] you need an additional volume or directory mounted to the
`/ngrams` directory. For that add a `-v` to the `docker run` command.

    docker run ... -v /foo:/ngrams ...

[ngrams]: http://wiki.languagetool.org/finding-errors-using-n-gram-data
### Manual

Download English ngrams with the commands:

    mkdir ngrams
    wget https://languagetool.org/download/ngram-data/ngrams-en-YYYYMMDD.zip
    (cd ngrams && unzip ../ngrams-en-YYYYMMDD.zip)
    rm -f ngrams-en-YYYYMMDD.zip

### Automatically

Mount a directory or volume to `/ngrams` and use the `NGRAM_LANGUAGES` variable to pass a comma separated string with languages:

    docker run ... -v /path/to/ngrams:/ngrams -e NGRAM_LANGUAGES="en,es" ...
