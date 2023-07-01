#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters. Example: sh apply.sh production customer1 infra"
fi

DIR="$1/$2/$3"

[ ! -d "$DIR" ] && echo "$DIR directory not exists." && exit 1

pushd $DIR

terraform apply -var environment="$1" -var customer="$2" -var home=${HOME}
