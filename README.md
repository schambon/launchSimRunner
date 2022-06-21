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
```

Note this uses m6g instances so the script installs Java for ARM. If you want to use Intel or AMD, replace ".aarch64" with ".x64_64" in the script.

Make sure you have AWS credentials in your env, then just run ./launch-simrunner.sh.

