#!/bin/bash

cd apps/get-recipe
GOOS=linux GOARCH=amd64 go build -o bootstrap main.go
zip function.zip bootstrap
cd ../../infra

terraform init
terraform apply -auto-approve