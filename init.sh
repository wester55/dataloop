#!/bin/bash

declare -a Customers=("customer1" "customer2" "global")

for cust in ${Customers[@]}; do
	cd production/$cust
	terraform init
	cd -
done
