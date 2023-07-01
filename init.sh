#!/bin/bash

not_contains() {
    [[ $1 =~ (^|[[:space:]])$2($|[[:space:]]) ]] && return 1 || return 0
}

declare -a Customers=("customer1" "customer2")
declare -a Environments=("production" "staging")
declare -a ExcludeCustomers=()
declare -a ExcludeEnvironment=("staging")
declare -a RunningOn=("infra" "apps")

for cust in ${Customers[@]}; do
	for envrmnt in ${Environments[@]}; do
		for dirname in ${RunningOn[@]}; do
			if not_contains $ExcludeCustomers $cust && not_contains $ExcludeEnvironment $envrmnt; then
				cd $envrmnt/$cust/$dirname
				terraform init
				cd -
			fi
		done
	done
done
