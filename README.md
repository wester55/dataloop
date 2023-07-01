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

The directory structure is:
.
├── README.md
├── applications
│   ├── grafana.tf
│   ├── nginx.tf
│   └── prometheus.tf
├── apply.sh
├── components
│   ├── aws_infra.tf
│   ├── common.tf
│   └── gcp_infra.tf
├── destroy.sh
├── init.sh
├── modules
│   ├── aks.tf
│   ├── eks.tf
│   ├── gke.tf
│   └── helm.tf
├── plan.sh
├── production
│   ├── customer1
│   │   ├── apps
│   │   │   ├── common.tf -> ../../../components/common.tf
│   │   │   ├── grafana.tf -> ../../../applications/grafana.tf
│   │   │   ├── helm.tf -> ../../../modules/helm.tf
│   │   │   ├── nginx.tf -> ../../../applications/nginx.tf
│   │   │   ├── prometheus.tf -> ../../../applications/prometheus.tf
│   │   │   └── terraform.tfstate
│   │   └── infra
│   │       ├── common.tf -> ../../../components/common.tf
│   │       ├── gcp_infra.tf -> ../../../components/gcp_infra.tf
│   │       ├── gke.tf -> ../../../modules/gke.tf
│   │       ├── terraform.tfstate
│   │       ├── terraform.tfstate.backup
│   │       └── terraform.tfvars
│   └── customer2
│       ├── apps
│       │   ├── common.tf -> ../../../components/common.tf
│       │   ├── grafana.tf -> ../../../applications/grafana.tf
│       │   ├── helm.tf -> ../../../modules/helm.tf
│       │   ├── nginx.tf -> ../../../applications/nginx.tf
│       │   ├── prometheus.tf -> ../../../applications/prometheus.tf
│       │   ├── terraform.tfstate
│       │   └── terraform.tfstate.backup
│       └── infra
│           ├── aws_infra.tf -> ../../../components/aws_infra.tf
│           ├── common.tf -> ../../../components/common.tf
│           ├── eks.tf -> ../../../modules/eks.tf
│           ├── terraform.tfstate
│           ├── terraform.tfstate.backup
│           └── terraform.tfvars
├── refresh.sh
└── staging
    ├── customer1
    │   ├── apps
    │   │   └── common.tf -> ../../../components/common.tf
    │   └── infra
    │       ├── common.tf -> ../../../components/common.tf
    │       └── terraform.tfvars
    └── customer2
        ├── apps
        │   └── common.tf -> ../../../components/common.tf
        └── infra
            ├── common.tf -> ../../../components/common.tf
            └── terraform.tfvars

