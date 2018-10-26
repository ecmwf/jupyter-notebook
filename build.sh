#!/usr/bin/env bash

set -e

here="$(cd $(dirname $0) && pwd)"

dot_netrc="${HOME}/.netrc"
if [ -r $dot_netrc ] ; then
  cp $dot_netrc ${here}/.netrc
fi

(cd ${here} &&
   docker build \
	  --build-arg=http_proxy=$http_proxy \
	  --build-arg=https_proxy=$https_proxy \
	  --build-arg=ftp_proxy=$ftp_proxy \
	  --build-arg=no_proxy=$no_proxy \
	  -t ecmwf/jupyter-notebook:latest \
	  -f ${here}/Dockerfile \
	  ${here})
