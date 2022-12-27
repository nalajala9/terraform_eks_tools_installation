#!/bin/bash

TYPE_OF_PROCESSOR=$(dpkg --print-architecture)
CLUSTER=my-cluster #Provide your custom name
REGION=$(aws ec2 describe-availability-zones --output text --query 'AvailabilityZones[0].[RegionName]')
VERSION=1.24 # provide your cluster version number
NODE_GROUP_NAME=${CLUSTER}-ng
KEY_NAME=amazonfirst-JavMvnJenTom # provide public key name available in the REGION 
NODE_TYPE=t2.medium 


sudo apt-get update -y
sudo apt-get install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" 
unzip awscliv2.zip
sudo ./aws/install
./aws/install -i /usr/local/aws-cli -b /usr/local/bin

if [ $TYPE_OF_PROCESSOR = "amd64" ] 
then
curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.23.13/2022-10-31/bin/linux/amd64/kubectl
curl -o kubectl.sha256 https://s3.us-west-2.amazonaws.com/amazon-eks/1.23.13/2022-10-31/bin/linux/amd64/kubectl.sha256
openssl sha1 -sha256 kubectl
chmod +x ./kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl
else
curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.23.13/2022-10-31/bin/linux/amd64/kubectl
curl -o kubectl.sha256 https://s3.us-west-2.amazonaws.com/amazon-eks/1.23.13/2022-10-31/bin/linux/amd64/kubectl.sha256
openssl sha1 -sha256 kubectl
chmod +x ./kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl
fi
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl create cluster --name $CLUSTER --region $REGION --zones=us-east-1a,us-east-1b,us-east-1c --without-nodegroup --version=$VERSION
eksctl utils associate-iam-oidc-provider \
    --region $REGION \
    --cluster $CLUSTER \
    --approve
eksctl create nodegroup --cluster=$CLUSTER \
                      --region=$REGION \
                      --name=$NODE_GROUP_NAME \
                      --node-type=$NODE_TYPE \
                      --nodes=2 \
                      --nodes-min=2 \
                      --nodes-max=4 \
                      --node-volume-size=20 \
                      --ssh-access \
                      --ssh-public-key=$KEY_NAME \
                      --managed \
                      --asg-access \
                      --external-dns-access \
                      --full-ecr-access \
                      --appmesh-access \
                      --alb-ingress-access \
                      --node-private-networking
