#!/usr/bin/env bash

# This script can be used to deploy a Play Framework service to a Linux server somewhere, e.g. an AWS EC2 instance.

SSH_PRIVATE_KEY=??? # Location of the private key to use for SSH access
INSTANCE_ADDRESS=??? # Public IP or DNS of the instance to deploy to
SERVICE_NAME=??? # Name of the service that is being deployed
SERVICE_VERSION=??? # Version of the service that is being deployed
PROD_CONFIG=??? # Location of the production config that will be deployed with the service

sbt clean compile dist

chmod 664 ${PROD_CONFIG}

scp -i ${SSH_PRIVATE_KEY} target/universal/${SERVICE_NAME}-${SERVICE_VERSION}.zip ${INSTANCE_ADDRESS}:/home/ubuntu/${SERVICE_NAME}.zip

scp -i ${SSH_PRIVATE_KEY} ${PROD_CONFIG} ${INSTANCE_ADDRESS}:/home/ubuntu/${SERVICE_NAME}.conf

ssh -i ${SSH_PRIVATE_KEY} ${INSTANCE_ADDRESS} << EOF
sudo kill -9 \$(cat ${SERVICE_NAME}-${SERVICE_VERSION}/RUNNING_PID)
sudo rm ${SERVICE_NAME}-${SERVICE_VERSION}/RUNNING_PID
sudo unzip -o ${SERVICE_NAME}.zip
sudo rm ${SERVICE_NAME}.zip
sudo ./${SERVICE_NAME}-${SERVICE_VERSION}/bin/${SERVICE_NAME} -Dconfig.file=${SERVICE_NAME}.conf &
EOF
