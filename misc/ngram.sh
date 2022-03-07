#!/usr/bin/env bash

set -euo pipefail

NGRAM_DATA_URL="https://languagetool.org/download/ngram-data/"
NGRAM_ARCHIVES=$(curl -sS "${NGRAM_DATA_URL}" | grep "\.zip" | grep -oP 'ngrams-\w\w-\d+\.zip' | sort | uniq)

TARGET_LANGS="${1}"
TARGET_DIR="${2}"

download_ngram() {
  local lang=$1
  local version=$2
  local directory=$3

  echo "Downloading: ${lang} - ${version}"
  rm -rf "${directory}/${lang}"
  curl --progress-bar "${NGRAM_DATA_URL}ngrams-${lang}-${version}.zip" |\
    bsdtar -x -f - -C "${directory}"
}


VERSION_FILE_CONTENT=

if test -f "${TARGET_DIR}/version"; then
  VERSION_FILE_CONTENT=$(cat "${TARGET_DIR}/version")
  >"${TARGET_DIR}/version"
fi

while read -r ngram_archive; do
  for lang in ${TARGET_LANGS/,/ }; do
    if echo "$(echo ${ngram_archive} | cut -d'-' -f2)" | grep -q $lang; then
      version=$(echo ${ngram_archive} | cut -d'-' -f3 | cut -d'.' -f1)
      if echo "${VERSION_FILE_CONTENT}" | grep -q "$lang"; then
        existing_version=$(echo "${VERSION_FILE_CONTENT}" | grep "${lang}" | cut -d':' -f2)
        current_version=$(echo "${ngram_archive}" | cut -d'-' -f3 | cut -d'.' -f1)
        if [[ "${existing_version}" -lt "${current_version}" ]]; then
          download_ngram "${lang}" "${version}" "${TARGET_DIR}"
        fi
      else
        download_ngram "${lang}" "${version}" "${TARGET_DIR}"
      fi
      echo "${lang}:${version}" >> "${TARGET_DIR}/version"
    fi
  done
done <<< "${NGRAM_ARCHIVES}"

for i in $(ls -d "${TARGET_DIR}"/*/); do
  realdir="$(basename ${i})"
  delete=yes
  for lang in ${TARGET_LANGS/,/ }; do
    if echo "${realdir}" | grep -q "${lang}"; then
      delete=no
    fi
  done
  if [ "${delete}" == "yes" ]; then
    rm -rf "${TARGET_DIR}/${realdir}"
  fi
done
