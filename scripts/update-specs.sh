#!/bin/bash

function updateSpec() {
    PACKAGE=$1
    EXECUTABLE=$2
    grep -v "Auto-generated dependency" packages/$PACKAGE/spec > packages/$PACKAGE/spec.new
    go list -f "{{ range .Deps }}- {{.}}/*.go # Auto-generated dependency
{{ end }}" $EXECUTABLE \
        | grep -e "\- github.com" -e "\- metrix" >> packages/$PACKAGE/spec.new
    mv packages/$PACKAGE/spec.new packages/$PACKAGE/spec
}

cd `git rev-parse --show-toplevel`

updateSpec talaria github.com/apoydence/talaria
