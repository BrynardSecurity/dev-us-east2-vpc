#!/bin/bash
# check if homebrew is installed
which -s brew
if [[ $? != 0 ]] ; then
    echo "Homebrew is not installed! Installing Homebrew..."
    # Install Homebrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo "Homebrew is installed! Updating Homebrew..."
    brew update
fi

# check if docker is installed
which -s docker
if [[ $? != 0 ]] ; then
    echo "Docker is not installed! Installing Docker..."
    brew cask install docker
else
    echo "Docker is installed! Proceeding with the rest of the script..."
fi

# check if aws cli is installed...

git clone --depth 1 \
    --filter=blob:none \
    --no-checkout \
    https://github.com/BrynardSecurity/dev-aws-kubernetes-vpc.git \
;

cd dev-aws-kubernetes-vpc
git checkout main -- terraform
cd dev-aws-kubernetes-vpc/terraform