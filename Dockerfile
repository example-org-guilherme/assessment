FROM hashicorp/terraform:1.5

WORKDIR /assignment

# Terraform init
COPY terraform terraform/
RUN cd terraform && terraform init

# Repositories
COPY repos repos/
RUN rm -rf repos/application/submodule-*

# Main dir
WORKDIR /assignment/terraform
RUN mkdir state