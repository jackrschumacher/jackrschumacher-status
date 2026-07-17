#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Builds the cState Hugo status page hosted on a Cloudflare Worker.
#
# Hugo version and edition are pinned in the .hvm file at the repo root
# (e.g., v0.163.3/standard) — the same file the shields.io badges read.
#------------------------------------------------------------------------------

main() {

  # Parse the .hvm format (e.g., v0.163.3/standard)
  HVM_CONTENT=$(cat .hvm | tr -d '\r\n')             # Strips hidden line endings
  HVM_VERSION=$(echo "$HVM_CONTENT" | cut -d'/' -f1) # e.g., v0.163.3
  HVM_EDITION=$(echo "$HVM_CONTENT" | cut -d'/' -f2) # e.g., standard
  RAW_VERSION="${HVM_VERSION#v}"                     # e.g., 0.163.3

  export TZ=America/Chicago

  # Install Hugo
  echo "Installing Hugo ${RAW_VERSION} (${HVM_EDITION})..."
  if [ "$HVM_EDITION" = "extended" ]; then
    HUGO_TARBALL="hugo_extended_${RAW_VERSION}_linux-amd64.tar.gz"
  else
    HUGO_TARBALL="hugo_${RAW_VERSION}_linux-amd64.tar.gz"
  fi

  curl -sLJO "https://github.com/gohugoio/hugo/releases/download/${HVM_VERSION}/${HUGO_TARBALL}"
  mkdir -p "${HOME}/.local/hugo"
  tar -C "${HOME}/.local/hugo" -xf "${HUGO_TARBALL}"
  rm "${HUGO_TARBALL}"
  export PATH="${HOME}/.local/hugo:${PATH}"

  # Verify installation
  echo Hugo: "$(hugo version)"

  # Configure Git
  echo "Configuring Git..."
  git config core.quotepath false
  if [ "$(git rev-parse --is-shallow-repository)" = "true" ]; then
    git fetch --unshallow
  fi

  # The cState theme is a git submodule; make sure it is present
  echo "Fetching theme submodule..."
  git submodule update --init --recursive

  # Build the site
  echo "Building the site..."
  hugo --gc --minify

}

set -euo pipefail
main "$@"
