#!/bin/sh

SCRIPT_HOME="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

DOCKER_ENV_FILE=$SCRIPT_HOME/.env

fn_down_microservices()
{
    local dockerComposeFile=$SCRIPT_HOME/docker-compose.yml
    docker compose --env-file $DOCKER_ENV_FILE \
        -f $dockerComposeFile down
    dockerComposeDownRc=$?
    if [ "$dockerComposeDownRc" != "0" ]; then
        echo "ERROR : Docker command 'docker compose --env-file $DOCKER_ENV_FILE -f $dockerComposeFile down' FAILURE ($dockerComposeDownRc)"
        exit $dockerComposeDownRc
    fi
    echo "INFO : Docker command 'docker compose --env-file $DOCKER_ENV_FILE -f $dockerComposeFile down' SUCCESS"
}

fn_remove_images()
{
	local serviceNodeImages=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep "aquasec/trivy")
	if [ ! -z "$serviceNodeImages" ]; then
		docker rmi -f $serviceNodeImages
	fi
	serviceNodeImages=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep "trivy-vulnerability-explorer")
	if [ ! -z "$serviceNodeImages" ]; then
		docker rmi -f $serviceNodeImages
	fi
}

source $DOCKER_ENV_FILE

fn_down_microservices
fn_remove_images
