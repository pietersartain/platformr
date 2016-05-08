# Platformr

The future of the web is API-based, with many different clients connecting to a central system.

As a developer, if you're lucky, that central system is nothing more than a web app and a database server. In this case, cloud providers have you covered, and have some neat tools to [allow you to just write your business code, and ignore the servers and storage](http://docs.aws.amazon.com/lambda/latest/dg/welcome.html).

For the rest of us, who need some more custom work, we have to dig a little and recreate some of the wonderful integrated solutions that others have provided. Since containers represent a middleground between the flexibility of managing servers and VMs, without the overheading of having to worry so much about tin, and there are a growing number of container-operating-systems, it's not a giant leap to expect larger backend systems to be microservice and container shaped, going forward.

So wouldn't it be nice if you could take the next logical step and deploy an entire container-based workflow in one click?

Platformr is an opinionated collection of tools that provide the CI build workflow, test pipelines, CD deployment and the monitoring and operational parts of a platform service.

# Usage

Right now, this deploys to a Linux host, using a [Docker-outside-of-Docker (DooD)](http://container-solutions.com/running-docker-in-jenkins-in-docker/) strategy for the agents.

On your Linux host (Debian, Ubuntu, et al), perform the following:

1. Sort out keys if you wish to use github private repos:
    1. Make some keys if you don't already have some with `make keys` or copy an existing RSA private key to `ssh/id_rsa`.
    2. [Configure Github with your key](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/)
2. Build the tools with `make` (this will do some `docker build`s)
3. Start the tools with `docker-compose up`.
4. Visit the Go.CD interface on [ip]:8153

Now it's up to you.

### Testing the build process

This test runs `docker ps` as a proof that docker can be run inside the agent container.

1. Configure a pipeline with appropriate materials
2. Pass in the appropriate argument into the build stage. Usually something like: `docker build -t build_test .`

Checking the host docker with `docker images` should show that something called build_test has been built. Additionally, checking the Go.CD console should clearly show the command has been executed successfully.

### Testing the upload to the container registry

This test uses the `google/cloud-sdk` and [`geertjohan/google-cloud-sdk-with-docker`](https://hub.docker.com/r/geertjohan/google-cloud-sdk-with-docker/) containers to demonstrates how to use containers as static applications (to avoid having to build the cloud-sdk into the gocd-agent) to deploy a `nginx` container to Google's Container Registry.

1. Pull a container to try and run, like `docker pull nginx`
2. Configure the gcloud container ([the instructions](https://hub.docker.com/r/google/cloud-sdk/)):
    `docker run -t -i --name gcloud-config google/cloud-sdk gcloud init`
3. Add a new pipeline which does the following two jobs:

```
    docker run --rm -ti 
    --volumes-from gcloud-config
    -v /var/run/docker.sock:/var/run/docker.sock
    geertjohan/google-cloud-sdk-with-docker 
    gcloud docker tag #{IMAGE_NAME} gcr.io/#{GOOGLE_PROJECT_ID}/#{IMAGE_NAME}
```
```
    docker run --rm -ti
    --volumes-from gcloud-config
    -v /var/run/docker.sock:/var/run/docker.sock 
    geertjohan/google-cloud-sdk-with-docker 
    gcloud docker push gcr.io/#{GOOGLE_PROJECT_ID}/#{IMAGE_NAME}
```

On the [Google Cloud Platform dashboard](https://console.cloud.google.com) you should be able to go to Container Engine -> Container Registry to see the image has been successfully pushed.

It would be wise to use Go.CDs "Parameters" section for the <google_project_id>, and the <image_name>

### Testing live deployment to kubernetes

This test takes the `nginx` container above.

1. Assume k8s is configured with a Deployment strategy

### Testing updating k8s


# Project Aims

1. Easy to get started.

A one-click deployment of the build/test/monitoring environment on a number of different platforms - getting this stuff running should not be hard. Ideally these can be different platforms for the running of the tools vs the deployment of the artefacts the tools produce.

 * Host target - where the tools are run.
 * Deployment target - where the build artefacts are deployed to and run.

Provisional targets include bare metal, AWS, GCE, DC/OS, CoreOS. We are starting with Kubernetes.

2. Easy to do the right thing.

There are common patterns in the construction of microservices (which are well documented), but platform patterns are less well documented, especially surrounding the build and test pipelines. These should be well documented and available to get you from ideation to implementation with the proper amount of maintainability of a large service.

This means we provide an barebones architectural guidebook for *your* system, to get you going down the right track.

3. Easy to learn from.

Like the idea of using Platformr, but need to work around an annoying process in your workplace? Need to use a different tool? You should be able to take the useful bits and hack them to suit your purpose, based on the self-documented code and other documentation available.

# TODO list

 * SSH keys should not be kept in the images. Get thee out! (Should also mean we can remove the gocd-docker submodule)
 * Make the gocd-server non-volatile with data containers / gcePersistentVolumes
 * Organise the repo around the host/deployment targets
 * Start arch manual
 * Deployment pipeline
    * Add default stages
    * Add git script for creating the right shape repos
 * Operations
    * API servers
    * Example Android app / web portal
 * Monitoring
    * Tech investigations
 * Get a full Kubernetes stack running
 * Investigate DC/OS baremetal stack.

# License & Copyright
The code is Copyright 2016 Pieter Sartain, and released under the MIT license. See license.txt for details.

# Random scratch notes.

Configuration management
 - Infrastructure-as-code
 - Immutable-infrastructure

[AWS Lamba](http://docs.aws.amazon.com/lambda/latest/dg/welcome.html)
Heroku
https://pagodabox.io/
https://dcos.io/

Jenkins
GO.CD

Docker-in-Docker (DinD) https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/
https://coreos.com/blog/building-minimal-containers-with-quay-kubernetes-wercker/
https://starefossen.github.io/post/2015/05/19/testing-docker-apps-with-wercker/


https://github.com/Travix-International/docker-gocd-server
https://github.com/phusion/baseimage-docker
