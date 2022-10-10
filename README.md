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

Note this uses m6g instances so the script installs Java for ARM. If you want to use Intel or AMD, replace ".aarch64" with ".x64_64" in the script.

Make sure you have AWS credentials in your env, then just run ./launch-simrunner.sh.

If you want to launch several Simrunners, set NUM_HOSTS and use ./multilaunch.sh. Some quality of life scripts for clustered running:
- copy_workload.sh just scp's the provided file onto the hosts you have provisioned with multilaunch
- atlas_add_ips.sh adds the public IP addresses of your hosts to your Atlas project with a 6h auto-delete
- collector_stanza.sh generates the list of hosts to poll for SimRunner-Collector
- start_all_simrunners.sh starts SimRunner on all hosts in the background
- stop_all_simrunners.sh stops SimRunner on all hosts

