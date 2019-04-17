#! /bin/bash

function usage {
    cat << EOF
Usage: ${0} DEPLOY_TO
Deploys to the DEPLOY_TO environment. 
EOF
}

function error {
    colour='\033[0;31m'
    standard='\033[0m'
    echo -e "${colour}ERROR: ${@}${standard}" >&2
}


set -eo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "${DRONE_BUILD_NUMBER}" ]; then
    # You will need to create the following file from the template
    if [[ ! -f "${SCRIPT_DIR}/deploy.cfg" ]];then
      error "Cound not find ${SCRIPT_DIR}/deploy.cfg; You will need to create it following file from the deploy.template.cfg file"
      exit 1
	 
    fi
    source "${SCRIPT_DIR}/deploy.cfg"
fi

DEBUG="${DEBUG:-}"

export DEPLOY_TO=${DEPLOY_TO:-${DRONE_DEPLOY_TO:-${1}}}
export BUILD_NUMBER=${DRONE_BUILD_NUMBER:-`date "+%Y%m%dt%H%M%S"`}
export ENV_BASE_DIR="${SCRIPT_DIR}/environments/${DEPLOY_TO}"

if [[ -z "${DEPLOY_TO}" ]] ; then
    error "Environment variable DEPLOY_TO was not set"
    echo
    usage
    exit 1
elif [[ ! -d "${ENV_BASE_DIR}" ]] ; then
    error "Environment variable DEPLOY_TO was not valid"
    exit 2
fi

# /usr/bin/git-set-creds-github.sh $github_ssh_key_cdp_deploy
TAG=$(cat ${ENV_BASE_DIR}/cdp-version)

CDP_DEPLOYMENT_TEMPLATES_DIR=${ENV_BASE_DIR}/cdp-deployment-templates
rm -rf ${CDP_DEPLOYMENT_TEMPLATES_DIR}
cd ${ENV_BASE_DIR}
git clone --branch ${TAG} --depth 1 git@github.com:UKHomeOffice/cdp-deployment-templates.git
cd -

set -a
source "${CDP_DEPLOYMENT_TEMPLATES_DIR}/vars/common.cfg"
source "${ENV_BASE_DIR}/conf.cfg"
set +a


if [[ -z "$DRONE_BUILD_NUMBER" ]];then
  kubectl="kubectl"
else
  kubectl="kubectl --insecure-skip-tls-verify --server=${KUBE_SERVER} --namespace=${KUBE_NAMESPACE} --token=${KUBE_TOKEN}"
fi

echo "Beginning deployment to ${DEPLOY_TO}."

kustomize build ${ENV_BASE_DIR}| envsubst | ${kubectl} apply -f - 

echo "All resources updated."

for d in `${kubectl} get deploy -o name`; do
    ${kubectl} rollout status "${d}"
done

echo "Complete."
