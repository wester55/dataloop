Requirements:

1. PATH to GCP service-account with permissions to create all resources, specify in components/gcp_infra.tf.
2. Authorize AWS CLI with relevant profile, for example: aws configure --profile production-customer2 

How to run:
1. Initialize: sh init.sh
2. Plan: sh plan.sh production customer2 infra
3. Apply: sh apply.sh production customer1 apps
4. Refresh: sh refresh.sh production customer1 infra
5. Destroy: sh destroy.sh staging customer2 apps

TBD: move same code from shell scripts to source file
