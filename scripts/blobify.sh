#!/bin/bash
set -e

workspace=$(git rev-parse --show-toplevel)
export GOPATH=$workspace

echo "building talaria node"
GOOS=linux go build -o $workspace/node github.com/apoydence/talaria/node
gzip -f $workspace/node

echo "building talaria scheduler"
GOOS=linux go build -o $workspace/scheduler github.com/apoydence/talaria/scheduler
gzip -f $workspace/scheduler

pushd $workspace > /dev/null
  bosh add-blob ./node.gz talaria/node.gz > /dev/null
  bosh add-blob ./scheduler.gz talaria/scheduler.gz > /dev/null
popd > /dev/null
