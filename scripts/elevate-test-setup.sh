#!/bin/bash
if [ ! -d tfstate ]; then
    if [ -e tfstate ]; then 
        echo "We need to create a folder called tfstate in this folder but it already exists, please delete it!"
        exit 1
    fi
    echo "Creating folder tfstate to share states with docker container :)"
    mkdir tfstate &>/dev/null
fi

docker run -it -v ./tfstate:/assignment/terraform/tfstate -e TF_VAR_owner -e TF_VAR_token elevate $@