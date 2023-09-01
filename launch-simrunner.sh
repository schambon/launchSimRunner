PURPOSETAG=other

source config.sh

export AWS_PAGER=""

echo "Spinning up AWS instance for SimRunner"
aws ec2 run-instances --image-id $IMAGE --count 1 --instance-type $INSTTYPE --key-name $KEYNAME \
  --security-group-ids $SECGROUP --block-device-mappings '[{"DeviceName": "/dev/xvda", "Ebs": {"DeleteOnTermination": true, "VolumeSize": 16, "VolumeType": "gp3"}}]' \
  --tag-specification "ResourceType=instance,Tags=[{Key=Name, Value=\"$NAMETAG\"},{Key=owner, Value=\"$OWNERTAG\"}, {Key=expire-on,Value=\"2023-12-31\"}, {Key=purpose,Value=\"$PURPOSETAG\"}]" > /dev/null

#sleep 20
sleep 10


res=$(aws ec2 describe-instances --filters "Name=tag:owner,Values=$OWNERTAG" "Name=tag:Name,Values=$NAMETAG" "Name=instance-state-name,Values=running")
PUBDNS=$(echo $res | jq -r '.Reservations[0].Instances[0].PublicDnsName')
PUBIP=$(echo $res | jq -r '.Reservations[0].Instances[0].PublicIpAddress')
echo $res
echo "Public DNS is $PUBDNS"
until test $PUBDNS != "null"
do
  sleep 1
  printf "."
  res=$(aws ec2 describe-instances --filters "Name=tag:owner,Values=$OWNERTAG" "Name=tag:Name,Values=$NAMETAG" "Name=instance-state-name,Values=running")
  PUBDNS=$(echo $res | jq -r '.Reservations[0].Instances[0].PublicDnsName')
  PUBIP=$(echo $res | jq -r '.Reservations[0].Instances[0].PublicIpAddress')
done

echo "Public DNS is $PUBDNS; waiting for ssh"

sleep 1
nc -z $PUBDNS 22
until test $? -eq 0
do
  sleep 1
  printf "."
  nc -z $PUBDNS 22
done

ssh -i $KEYPATH -oStrictHostKeyChecking=no ec2-user@$PUBDNS <<EOF
sudo yum install -y git maven java-17-amazon-corretto-devel
sudo alternatives --set java /usr/lib/jvm/java-17-amazon-corretto.aarch64/bin/java
sudo alternatives --set javac /usr/lib/jvm/java-17-amazon-corretto.aarch64/bin/javac
git clone https://github.com/schambon/SimRunner.git
cd SimRunner
mvn clean package
cp bin/SimRunner.jar ~
EOF

echo "Public DNS is $PUBDNS; Public IP is $PUBIP"
