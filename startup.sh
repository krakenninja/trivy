#!/bin/sh
SCRIPT_HOME="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

DOCKER_ENV_FILE=$SCRIPT_HOME/.env

TRIVY_VULNERABILITY_EXPORER_SRC_DIR="$SCRIPT_HOME/trivy-vulnerability-explorer"

fn_setup_microservices()
{
    # prepare clone dir
    if [ -d "$TRIVY_VULNERABILITY_EXPORER_SRC_DIR" ]; then
        local old_pwd_dir=$(echo $PWD)
        cd "$TRIVY_VULNERABILITY_EXPORER_SRC_DIR"
        git fetch "origin"
        git reset --hard "origin/main"
        cd $old_pwd_dir
    else
        mkdir -p "$TRIVY_VULNERABILITY_EXPORER_SRC_DIR"
        git clone -b "main" "https://github.com/dbsystel/trivy-vulnerability-explorer.git" "$TRIVY_VULNERABILITY_EXPORER_SRC_DIR"
    fi
}

fn_build_microservices()
{
    local old_pwd_dir=$(echo $PWD)
    cd "$TRIVY_VULNERABILITY_EXPORER_SRC_DIR"
    docker build -t dbsystel/trivy-vulnerability-explorer:latest .
    cd $old_pwd_dir
}

fn_start_microservices()
{
    local dockerComposeFile=$SCRIPT_HOME/docker-compose.yml
    docker compose --env-file $DOCKER_ENV_FILE \
        -f $dockerComposeFile up -d
    dockerComposeUpRc=$?
    if [ "$dockerComposeUpRc" != "0" ]; then
        echo "ERROR : Docker command 'docker compose --env-file $DOCKER_ENV_FILE -f $dockerComposeFile up' FAILURE ($dockerComposeUpRc)"
        exit $dockerComposeUpRc
    fi
    echo "INFO : Docker command 'docker compose --env-file $DOCKER_ENV_FILE -f $dockerComposeFile up' SUCCESS"
}

source $DOCKER_ENV_FILE

fn_setup_microservices
fn_build_microservices
fn_start_microservices
