# cdp-environments
Demo configuration for non-prod CDP environments



Deployment repo for Common Data Platform
========================================

This repository contains the deployment files, config and pipeline for the
Common Data Platform (CDP).


Services provided
-----------------

1. GraphDB (JanusGraph) (Work in progress!)
2. ElasticSearch (for dev purposes only)


Notable directories
-------------------
`conf-template/` contains configuration templates with environment variable placeholders for each of the major cdp components.
`conf-template/graphdb/common/` contains the common files for all the different graphdb personas
`conf-template/graphdb/persona/schema-loader/` contains the configuration files needed by the 'schema-loader' graph persona.  This  persona will apply a new graph schema to the environment.

`environments/` contains variables that are used across environments (common.cfg), as well as environment-specific variables substituted into the Kubernetes.  The environment-specific directory also contains a  kustomization.yml file, which selects what components will be deployed in each environment, as well as a cdp-version file.  The contents of the cdp-version file should match a subdirectory under the manifest directory.



`k8s-template/` contains the Kubernetes template files.

`manifest/<cdp-version>` contains the URL to the image of each of the components.

`manifest/latest` a sym link to the lastest version (this is what the components will use to auto-register their latest version once all the tests pass).


Deploying from your local machine
--------------------------------

1. Create your config file:

```shell
cp ./deploy.cfg.template ./deploy.cfg
```

2. Edit the file to contain your secrets.

3. Run the deployment script, providing the environment you wish to deploy to as an environment variable (DEPLOY_TO):

```shell
export DEPLOY_TO=cdp-dev
./deploy.sh 
```


Adding a new component
----------------------

To add a new component, the following changes are needed:
1. create a new .yaml file in k8s-template  directory.  Note that file name should match the name of the service.
2. optionally add one or more configuration file templates (if the application requires) under the conf-template directory.  These files may have placeholders that are replaced with environment variables listed under environments/common.cfg and environments/<namespace>/conf.cfg.  
WARNING: IF THE FILES END IN ANYTHING OTHER THAN .yaml, .yml, .json, .properties, THE deploy.sh FILE will have to be UPDATED (around line 68).
3. edit the environments/common.cfg and environments/<namespace>/conf.cfg to add any new placeholders
4. edit the environments/<namespace>/kustomization.yaml file to add the new templates from step (1), and files from step (2).  Note that the deployment script replaces environment variables in these files, so the actual file names are under a dynamic folder (not added to git), called resolved (e.g. if a template file under k8s-template/foo.yaml is to be added, the entry in resources should be resolved/k8s/foo.yaml); similarly, if a config file under conf-template/foo/foo.properties is to be added, the configMapGenerator should have an entry similar to this:

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
3. cdp-version - the contents of this file match a subdirectory under the 'manifest/'  directory.

Create the following kube secrets:
* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY

Create the following Drone secrets:
* KUBE_TOKEN="XXXXXXX"
* KUBE_SERVER="https://YYYYYYY"

