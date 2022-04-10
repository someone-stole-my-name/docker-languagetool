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

Route information can be found at https://languagetool.org/http-api/swagger-ui/#/default, an easy route to test that it's running is `/v2/languages`.

## Configuration

### Java heap size

You can set any Java related option using the `JAVAOPTIONS` environment variable. 

    docker run --rm -it -p 8010:8010 -e JAVAOPTIONS="-Xmx382M" ghcr.io/someone-stole-my-name/docker-languagetool:latest

### HTTPServerConfig

Any environment variable prefixed with `LT_` is interpreted as an [HTTPServerConfig] option.

    docker run --rm -it -p 8010:8010 -p 9301:9301 \
      -e LT_prometheusMonitoring=true \
      ghcr.io/someone-stole-my-name/docker-languagetool:latest
    [...]
   
    curl -s localhost:9301 | grep -v '^\s*$\|^\s*\#'                                                                                                            (k8s-pro)
    languagetool_check_matches_total{language="en",mode="ALL",} 1.0
    languagetool_threadpool_queue_size{pool="lt-server-thread",} 0.0
    [...]

### n-gram dataset support

To support [ngrams] you need an additional volume or directory mounted to the `/ngrams` directory.

    docker run ... -v /foo:/ngrams ...

### Automatic download

This image can take care of the initial download of any ngram supported language as well as updates. 
Mount a directory or volume to `/ngrams` and use the `NGRAM_LANGUAGES` environment variable to pass a comma separated string with languages:

    docker run ... -v /path/to/ngrams:/ngrams -e NGRAM_LANGUAGES="en,es" ...

### Manual download

Download and unzip any language with the commands:

    mkdir ngrams
    wget https://languagetool.org/download/ngram-data/ngrams-en-YYYYMMDD.zip
    (cd ngrams && unzip ../ngrams-en-YYYYMMDD.zip)
    rm -f ngrams-en-YYYYMMDD.zip

It is important that the directory structure ends up looking like:

    ngrams/
     en/
      ...
     es/
      ...


[ngrams]: http://wiki.languagetool.org/finding-errors-using-n-gram-data
[HTTPServerConfig]: https://languagetool.org/development/api/org/languagetool/server/HTTPServerConfig.html
