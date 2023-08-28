# Flask Hello World Application

This repository contains a simple Python Flask application that prints "Hello, World!" when accessed. The application is deployed using a combination of Docker, Terraform, Kubernetes, and Ansible. The entire deployment process is automated using Jenkins and a custom Jenkins shared library.

## Technologies Used

- Python: The application is built using Python and the Flask web framework.
- Docker: The application is containerized using Docker to ensure consistency in different environments.
- Terraform: Terraform is used to provision the infrastructure, including an Amazon EKS cluster and an Amazon EC2 instance.
- Ansible: Ansible is employed to configure the provisioned instances and manage the application deployment.
- Kubernetes: Kubernetes is used to manage and orchestrate the deployment of the Flask application.
- Jenkins: Jenkins is the automation server that runs the deployment pipeline.
- Jenkins Shared Library: A custom Jenkins shared library named jenkins-shared-library is used to encapsulate common pipeline logic and steps.

## Getting Started

WIP

## Deployment Process

1. The Jenkins pipeline (Jenkinsfile) triggers automatically whenever changes are pushed to the repository.
2. The pipeline starts by building the Docker image for the Flask application.
3. Once the Docker image is built, the pipeline uses Terraform to provision an Amazon EKS cluster and an EC2 instance.
4. Ansible then configures both the EKS cluster and the EC2 instance according to the defined specifications.
5. The pipeline leverages Kubernetes to deploy the Flask application to the provisioned EKS cluster.
6. The entire deployment process, including all stages, is orchestrated and automated by the Jenkins pipeline.

## [Jenkins Shared Library](https://github.com/mahmoudk1000/jenkins-shared-library)

The jenkins-shared-library contains custom pipeline steps and logic that streamline the deployment process across multiple projects. It encapsulates best practices and reusable code to enhance maintainability and consistency in Jenkins pipelines.

## Conclusion

This repository demonstrates how to automate the deployment of a simple Python Flask application using Docker, Terraform, Kubernetes, and Ansible. The Jenkins pipeline, along with the custom Jenkins shared library, automates the entire deployment process from code to production. This approach enhances efficiency, repeatability, and consistency in the deployment lifecycle.

Feel free to explore or to fix the provided code, adapt it to your needs, and extend it to more complex applications. Happy deploying!
