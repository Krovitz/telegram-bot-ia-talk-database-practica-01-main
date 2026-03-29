#!/bin/bash
set -e
# install clientes
sudo apt-get update && sudo apt-get install -y  mariadb-client postgresql-client

echo "Configurando AWS..."
mkdir -p /home/vscode/.aws
cp /workspaces/telegram-bot-ia-talk-database-practica-01/k8s/aws/config /home/vscode/.aws/config
cp /workspaces/telegram-bot-ia-talk-database-practica-01/k8s/aws/credentials /home/vscode/.aws/credentials

echo "Configurando AWS CLI..."
aws sts get-caller-identity --no-cli-pager

echo "Configurando kubectl... eks-2025-1"
aws eks update-kubeconfig --name eks-2025-1 --region us-east-1
