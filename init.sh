#!/bin/bash

not_contains() {
    [[ $1 =~ (^|[[:space:]])$2($|[[:space:]]) ]] && return 1 || return 0
}

declare -a Customers=("customer1" "customer2" "global")
declare -a Environments=("production" "staging")
declare -a ExcludeCustomers=("customer2")
declare -a ExcludeEnvironment=("staging")

for cust in ${Customers[@]}; do
	for envrmnt in ${Environments[@]}; do
		if not_contains $ExcludeCustomers $cust && not_contains $ExcludeEnvironment $envrmnt; then
			cd $envrmnt/$cust
			terraform init
			cd -
		fi
	done
done
