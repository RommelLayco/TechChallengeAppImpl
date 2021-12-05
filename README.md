# TechChallengeAppImpl

Implementation of the tech challenge App deployment

## Prequistes

* terraform
* helm v3

## Deployment

To deploy the application complete the following steps

1. Run the commands to initiliase terraform

    ```bash
    cd terraform
    terraform init
    ```

2. Create a new terraform workspace or select an existing workspace

    ```bash
    # new workspace
    terraform workspace new dev
    terraform init

    # or existing workspace
    terraform workspace select dev
    ```

3. Create or update a config file containing the terraform variables see `config/dev.tfvars` for an example

4. Set the following environment variable to set the rds Password

    ```bash
    # Replace password with a secure password
    export TF_VAR_db_admin_password=password
    ```

5. Review then apply the configuration

    ```bash
    terraform apply -var-file config/dev.tfvars
    ```
