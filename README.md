# TechChallengeAppImpl

Implementation of the tech challenge App deployment

## Prequistes

* terraform
* helm v3
* In the aws account you are deploying this stack ensure that there is role called `KubeAdmin`. This role will be used for kubectl access to the cluster.

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

6. Update KubeConfig with the following command

    ```bash
    # You can get the values of the variables from the terraform outputs
    # note aws_profile should contain credentials from the `KubeAdmin` Role
    aws eks update-kubeconfig --region ${AWS_REGION} --profile ${AWS_PROFILE} --name ${CLUSTER_NAME}
    ```

7. Copy the values.yaml and create a new file e.g. values-dev.yaml. These values will be used to deploy the helm chart

8. Install helm chart

    ```bash
    # replace values-dev.yaml with your created values file
    # replace password with the password of the database
    helm upgrade app charts/application --install -f charts/application/values-dev.yaml --set config.dbPassword=password 
    ```

9. Run the command to get the address of the load balancer

    ```bash
    kubectl get svc
    ```

**NB** You may need to wait a couple of minutes for the load balancer to initiliase before you can attempt to connect.
