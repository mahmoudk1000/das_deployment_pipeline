#!/usr/bin/env groovy

library identifier: 'jenkins-shared-library@master', retriver: modernSCM(
    [
        $class: 'GitSCMSource',
        remote: 'https://github.com/mahmoudk1000/jenkins-shared-library.git',
    ]
)

pipeline {
    agent any

    environment {
        IMAGE_NAME = "mahmoudk1000/app:v1.0"
    }

    stages {
        stage('Test App') {
            steps {
                script {
                    echo 'Testing application...'
                    dir('src') {
                        sh 'python3 -m venv venv'
                        sh 'source venv/bin/activate'
                        sh 'pip install -r requirements.txt'
                        sh 'python -m pytest app.py'
                    }
                }
            }
        }

        stage('Build App') {
            steps {
                script {
                    echo 'Building application...'
                        sh 'python ./src/setup.py sdist'
                }
            }
        }

        stage('Build Dokcer Image') {
            steps {
                script {
                    echo 'Build docker image...'
                    dockerLogin()
                    buildDockerImage(env.IMAGE_NAME, "Dockerfile")
                    dockerPush(env.IMAGE_NAME)
                }
            }
        }

        stage('Provision ec2 Instance using Terraform') {
            steps {
                script {
                    dir('terraform') {
                        sh 'terraform init'
                        sh 'terraform apply --auto-approve'
                    }
                }
            }
        }

        stage('Configure ec2 Instance using Ansbile') {
            steps {
                stage('Copy necessary file to Ansbile') {
                    script {
                        echo "Copy necessary files to Ansbile control node"
                        sshagent(['ansible-server-key']) {
                            sh "scp -o StrictHostKeyChecking=no ansible/* root@_IP_OF_ANSIBLE_NODE_:/root"
                            withCredentials([sshUserPrivateKey(credetialsId: 'ec2-server-key', keyFileVariable: 'keyfile', userVariable: 'user')]) {
                                sh 'scp $keyfile root@_IP_OF_ANSIBLE_NODE_:/root/ssh-key.pem'
                            }
                        }
                    }
                }
                stage('Executing Ansbile play-book') {
                    script{
                        echo "Run Ansbile play-book"
                        def remote = [:]
                        remote.name = "ansible-server"
                        remote.host = "_IP_OF_ANSIBLE_NODE_"
                        remote.allowAnyHosts = true
                        
                        withCredentials([sshUserPrivateKey(credetialsId: 'ansible-server-key', keyFileVariable: 'keyfile', userVariable: 'user')]) {
                            remote.user = user
                            remote.identityFile = keyfile
                            sshCommand remote: remote, command: "ansible-playbook deploy_app.yaml"
                        }
                    }
                }
            }
        }

        stage('Deply') {
            steps {
                script {
                    echo 'Deploy application image to server...'

                    sshagent(['ec2-server-key']) {
                        sh "scp server Dockerfile ${ec2Instance}:/home/ec2-user"
                    }
                }
            }
        }
    }
}
