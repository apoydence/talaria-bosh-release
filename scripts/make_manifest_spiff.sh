#!/bin/bash

set -e

RELEASE_DIR=`git rev-parse --show-toplevel`

if [[ -z $DEPLOYMENT ]]; then
    DEPLOYMENT=$1
fi
if [[ -z $DEPLOYMENT ]]; then
    echo "Usage: $0 manifest_stub_path <deployment> [manifest-file]"
    exit 1
fi

if [[ -z $MANIFEST_FILE ]]; then
    MANIFEST_FILE=$2
fi

echo "Working directory: $(pwd)"

DEPLOYMENT_FILE=`basename $DEPLOYMENT`
DEPLOYMENT_ENV=`basename $(dirname $DEPLOYMENT)`

MANIFEST_FILE=${PWD}/${MANIFEST_FILE:-tmp/${DEPLOYMENT_FILE/stub/$DEPLOYMENT_ENV}}

echo "Writing manifest to ${MANIFEST_FILE}"
MANIFEST_FILE_TMP=${MANIFEST_FILE}_tmp

output_dir=$(dirname ${MANIFEST_FILE})
if [[ ! -e "$output_dir" ]]; then
    mkdir -p $output_dir
fi

cp $DEPLOYMENT $MANIFEST_FILE_TMP
if [[ -z $DIRECTOR_UUID ]]; then
    DIRECTOR_UUID=$(bosh status | grep UUID | awk '{print $2}')
else
    echo "Found director UUID in environment, not loading from bosh"
fi

spiff merge $RELEASE_DIR/templates/talaria.yml $MANIFEST_FILE_TMP > $MANIFEST_FILE

echo "Director UUID: $DIRECTOR_UUID"
perl -pi -e "s/PLACEHOLDER-DIRECTOR-UUID/$DIRECTOR_UUID/g" $MANIFEST_FILE

pushd $(dirname "$0")
  GIT_SHA=`git rev-parse --verify HEAD`
  echo "Git SHA: $GIT_SHA"
  perl -pi -e "s/PLACEHOLDER-VERSION-SHA/$GIT_SHA/g" $MANIFEST_FILE
popd

rm $MANIFEST_FILE_TMP

if [[ "${BOSH_ENV}" != "concourse" ]]; then
    echo "Setting manifest file to $MANIFEST_FILE..."
    bosh deployment $MANIFEST_FILE
    $RELEASE_DIR/scripts/update-specs.sh
fi
