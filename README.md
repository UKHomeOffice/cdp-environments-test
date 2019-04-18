# cdp-environments
Demo configuration for non-prod CDP environments



Deployment repo for Common Data Platform
========================================

This repository contains the config and pipeline for the
Common Data Platform (CDP).


Services provided
-----------------

1. GraphDB (JanusGraph) (Work in progress!)
2. ElasticSearch (for dev purposes only)


Notable directories
-------------------
[`environments/`](./environments/) contains environment-specific variables substituted into the Kubernetes resource definitions.  The environment-specific directory also contains a  `kustomization.yml` file, which selects what components will be deployed in each environment, as well as a `cdp-version` file.  The contents of the `cdp-version` file should match a tag defined in the [cdp-deployment-templates](https://github.com/UKHomeOffice/cdp-deployment-templates) repo.


Deploying from your local machine
--------------------------------

1. Edit the file to contain your secrets (`deploy.cfg` - use [`deploy.template.cfg`](./deploy.template.cfg) as a template).

2. Run the deployment script, providing the environment you wish to deploy (e.g. `cdp-dev`) as the second parameter to the docker container's deploy.sh script.
The docker container's working directory should be the base of the [cdp-environments](https://github.com/UKHomeOffice/cdp-environments) repo.
It should be mounted as a volume provided to the `deploy.sh` script as the first parameter.

```shell
docker run -it --rm -v `pwd`:/cdp-environments quay.io/ukhomeofficedigital/cdp-ci deploy.sh /cdp-environments cdp-dev
```

3. Run the deployment script, providing the environment you wish to deploy to as an environment variable (DEPLOY_TO):

```shell
export DEPLOY_TO=cdp-dev
./deploy.sh 
```


Adding a new component
----------------------

To add a new component, follow the instructions in the [README](https://github.com/UKHomeOffice/cdp-deployment-templates/blob/master/README.md) file from the cdp-deployment-templates repo . The following changes are also needed:
3. edit `environments/<namespace>/conf.cfg` to add any new placeholders
4. edit the `environments/<namespace>/kustomization.yaml` file to add the new templates from step (1), and files from step (2) from [README](https://github.com/UKHomeOffice/cdp-deployment-templates/blob/master/README.md).  If a config file under conf-template/foo/foo.properties is to be added, the configMapGenerator should have an entry similar to this:

``` configMapGenerator:
  - name: foo
    files:
      - resolved/conf/foo/foo.properties
```


Adding a new environment
------------------------

To add a new environment, copy the configuration files from one of the directories under the environments folder, and edit the three files appropriately:
1. conf.cfg - environment-specific env vars; note that these override the env vars under environments/common.cfg.  
2. kustomization.yaml - tailor this if any parts of the deployment are not applicable to this particular environment
3. cdp-version - the contents of this file match a tag from the [cdp-deployment-templates](https://github.com/UKHomeOffice/cdp-deployment-templates) git repo. Depending on the risk appetite, a floating tag named after namespaces can be used (e.g. `cdp-dev`)

4. Create the following kube secrets:

* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY

5. Create the following Drone secrets:

* KUBE_TOKEN="XXXXXXX"
* KUBE_SERVER="https://YYYYYYY"

