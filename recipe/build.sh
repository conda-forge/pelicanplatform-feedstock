#!/bin/bash

set -ex

# dynamically generate content
GOARCH="" GOOS="" go generate ./...

# set variables for build
CONFIG_PKG="github.com/pelicanplatform/pelican/config"
LDFLAGS="
  -s
  -w
  -X ${CONFIG_PKG}.version=${PKG_VERSION}
  -X ${CONFIG_PKG}.commit=v${PKG_VERSION}
  -X ${CONFIG_PKG}.date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  -X ${CONFIG_PKG}.builtBy=conda-forge
"

# build and install
go build \
  -a \
  -ldflags "${LDFLAGS}" \
  -tags forceposix \
  -p ${CPU_COUNT} \
  -v \
  -o "${PREFIX}/bin/pelican" \
  ./cmd

# generate the license pack
go get ./...
go-licenses save ./cmd --save_path license-files --ignore modernc.org\/mathutil
