# TERRAFORM_DEMOS

## THIS IS AWESOME

## THIS IS TO CREATE TAG v1.0.0.

## FROM RELEASE BRANCH: v1.0.0

## Commands to build and push the docker image after change to terraform version 1.10.2
cd /path/to/your/dockerfile
docker build -t vidaldocker/mastertf:kn1.0.3 .
docker login
docker push vidaldocker/mastertf:kn1.0.3
