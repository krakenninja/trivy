#!/bin/sh
SCRIPT_HOME="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

DOCKER_ENV_FILE=$SCRIPT_HOME/.env

fn_stop_microservices()
{
    local dockerComposeFile=$SCRIPT_HOME/docker-compose.yml
    docker compose --env-file $DOCKER_ENV_FILE \
        -f $dockerComposeFile stop
    dockerComposeStopRc=$?
    if [ "$dockerComposeStopRc" != "0" ]; then
        echo "ERROR : Docker command 'docker compose --env-file $DOCKER_ENV_FILE -f $dockerComposeFile stop' FAILURE ($dockerComposeStopRc)"
        exit $dockerComposeStopRc
    fi
    echo "INFO : Docker command 'docker compose --env-file $DOCKER_ENV_FILE -f $dockerComposeFile stop' SUCCESS"
}

source $DOCKER_ENV_FILE

fn_stop_microservices
