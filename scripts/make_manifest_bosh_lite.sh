#!/bin/bash -e

RELEASE_DIR=`git rev-parse --show-toplevel`
cd $RELEASE_DIR

DEPLOYMENT=$1
if [[ -z $DEPLOYMENT ]]; then
  DEPLOYMENT=templates/bosh-lite/bosh-lite.yml
fi
echo "Using stub $DEPLOYMENT"

mkdir -p tmp

DEPLOYMENT_FILE=`basename $DEPLOYMENT`
DEPLOYMENT_ENV=`basename $(dirname $DEPLOYMENT)`
MANIFEST_FILE=tmp/${DEPLOYMENT_FILE/stub/$DEPLOYMENT_ENV}

./scripts/make_manifest_spiff.sh $DEPLOYMENT $MANIFEST_FILE

sed -i '' '/persistent_disk:/d' $MANIFEST_FILE
