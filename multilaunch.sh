# some default values
PURPOSETAG=other
NUM_HOSTS=1
EXPIREON=2023-12-31

source config.sh

export AWS_PAGER=""

echo "Spinning up $NUM_HOSTS AWS instance(s) for SimRunner"
aws ec2 run-instances --image-id $IMAGE --count $NUM_HOSTS --instance-type $INSTTYPE --key-name $KEYNAME \
  --security-group-ids $SECGROUP --block-device-mappings '[{"DeviceName": "/dev/xvda", "Ebs": {"DeleteOnTermination": true, "VolumeSize": 16, "VolumeType": "gp3"}}]' \
  --tag-specification  "ResourceType=instance,Tags=[{Key=Name, Value=\"$NAMETAG\"},{Key=owner, Value=\"$OWNERTAG\"}, {Key=expire-on,Value=\"$EXPIREON\"}, {Key=purpose,Value=\"$PURPOSETAG\"}]" 

#sleep 20
sleep 10


res=$(aws ec2 describe-instances --filters "Name=tag:owner,Values=$OWNERTAG" "Name=tag:Name,Values=$NAMETAG" "Name=instance-state-name,Values=running")

for inst in $(echo $res | jq -c -r ".Reservations[].Instances[]");
do
  INSTANCEID=$(echo $inst | jq -r '.InstanceId')
  PUBDNS=$(echo $inst | jq -r '.PublicDnsName')
  PUBIP=$(echo $inst | jq -r '.PublicIpAddress')
  until test $PUBDNS != "null"
  do
    sleep 1
    printf "."
    inst=$(aws ec2 describe-instances --instance-ids $INSTANCEID | jq -r ".Reservations[].Instances[0]")
    PUBDNS=$(echo $inst | jq -r '.PublicDnsName')
    PUBIP=$(echo $inst | jq -r '.PublicIpAddress')
  done
  echo "Public DNS is $PUBDNS; waiting for ssh"
  nc -z $PUBDNS 22
  until test $? -eq 0
  do
    sleep 1
    printf "."
    nc -z $PUBDNS 22
  done

ssh -i $KEYPATH -oStrictHostKeyChecking=no ec2-user@$PUBDNS <<EOF
sudo dnf install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
newgrp docker
EOF
done



res=$(aws ec2 describe-instances --filters "Name=tag:owner,Values=$OWNERTAG" "Name=tag:Name,Values=$NAMETAG" "Name=instance-state-name,Values=running")
echo "Public DNS names:"
echo $res | jq -r ".Reservations[].Instances[].PublicDnsName"
echo ""
echo "Public IP addresses:"
echo $res | jq -r ".Reservations[].Instances[].PublicIpAddress"

if [ -n "$1" ]; then
./copy_workload.sh $1
fi

./atlas_add_ips.sh
