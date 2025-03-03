Launch SimRunner
================

Handy script to create a SimRunner instance in EC2.

Create a config.sh file with contents like this:

```
KEYNAME=(name of your keypair)
KEYPATH=(path to your key .pem file)
SECGROUP=(id of your security group, like sg-...)
IMAGE=ami-00f13602fa9acface
NAMETAG=(name tag)
OWNERTAG=(owner tag)
INSTTYPE=m6g.xlarge
PURPOSETAG=(purpose tag)

NUM_HOSTS=1
ATLASAPIKEY=(Atlas API key)
ATLASAPIPRIVKEY=(Atlas private API key)
ATLASGROUP=(Atlas project ID)
```

Make sure you have AWS credentials in your env, then just run `./multilaunch.sh <path to your workload file>`. Under the hood, this provisions EC2 instances, installs Docker on them and launches the Simrunner image from Dockerhub (`sylvainchambon/simrunner:latest`).

If you want the HTTP interface for metrics and/or clustering, make sure that your workload file listens to port 3000 on host 0.0.0.0.

This package contains several scripts to run Simrunner:
- `copy_workload.sh` scp's the provided file onto the hosts you have provisioned with multilaunch
- `start_all_simrunners.sh` starts SimRunner on all hosts in the background
- `stop_all_simrunners.sh` stops SimRunner on all hosts

In addition, the following scripts are called as part of `multilaunch` but can be used independently if needed:
- `atlas_add_ips.sh` adds the public IP addresses of your hosts to your Atlas project with a 6h auto-delete
- `collector_stanza.sh` generates the list of hosts to poll for SimRunner-Collector