#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters. Example: sh plan.sh production customer1"
fi

DIR="$1/$2"

[ ! -d "$DIR" ] && echo "$DIR directory not exists." && exit 1

pushd $DIR

terraform plan -var environment="$1" -var customer="$2" -var home=${HOME}
