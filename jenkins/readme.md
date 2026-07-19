How to setup jenkins for Hospitia project

pre-requisite:
docker should be installed in host machine


run below commands to clone jenkins infra directory

you can see .sample.env file in the clonned repository.
Now run below command to create .env file
cp .sample.env .env

Below is the description of each variable present in .env file
TODO: Write one liner for below variable
CASC_JENKINS_CONFIG
JENKINS_ADMIN_USERNAME
JENKINS_ADMIN_PASSWORD
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
JENKINS_URL
JENKINS_ADMIN_EMAIL
JAVA_OPTS=-Djenkins.install.runSetupWizard=false

for git hub private key, generate rsa private - public key pair. Add public ssh key in you github account ssh key and add private ssh key in env file. Also, we recommanded to set username other than your actual username for e.g. jenkins so action performed by jenkins can be identified clearly.


then run below command to spinup jenkins container
docker compose up -f docker-compose.yml -d

As we are using JCasC (Jenkins as Code), once container is spinned up you are directly ready to user jekins.

Enter localhost:9000 (Or valid http(s) url of server where you hosted jenkins) and endter admin username and password which you mentioned in the .env file while spinning up container.

sudo cat abc | tr -d '\n'

## build docker image for jenkins agent
All dockerfiles to build docker jenkins agent docker image will be inside /jenkins/agents directory

then run below command to command to execute script which will build agents image and push them to the docker hub.
Note: This script will ask for credentials to login into your docker hub

how we maintain agent image version?
Suppose we are building node22 image for the jenkins slave
When initially build image we will give it tag like node22-v1. With this tag we will push node22-latest tag everytime we build image.
Now suppose we change something and want to build the image againg then we will increase version number like node22-v2, node22-v3 etc. but with every build we are pushing node22-latest tag (which will be use in jenkins node) so everytime jenkins will spawn container with latest change and at the same time we will be able to maintain build history of images

you can run below command to build agent image inside jenkins/agents directory
bash ./build-agents.sh <dockerhub-username> <dockerhub-access-token> <agent-name> <version>

machine hosting jenkins agent container must have docker installed