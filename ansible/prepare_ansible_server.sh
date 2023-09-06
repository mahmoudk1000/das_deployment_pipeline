#!/usr/bin/env bash

yum update
yum install python3 python3-pip -y
yum install ansible -y

pip3 install boto3 botocore
