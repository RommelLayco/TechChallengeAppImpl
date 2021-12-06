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

7. Install helm chart

    ```bash
    helm install app charts/application 
    # replace password with the password of the database
    helm upgrade app charts/application --install --set config.dbPassword=password 
    ```

8. Run the command to get the address of the load balancer

    ```bash
    kubectl get svc
    ```
