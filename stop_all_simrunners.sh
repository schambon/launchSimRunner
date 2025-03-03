source config.sh

export AWS_PAGER=""

res=$(aws ec2 describe-instances --filters "Name=tag:owner,Values=$OWNERTAG" "Name=tag:Name,Values=$NAMETAG" "Name=instance-state-name,Values=running")
echo "Public DNS names:"
echo $res | jq -r ".Reservations[].Instances[].PublicDnsName"


for inst in $(echo $res | jq -r ".Reservations[].Instances[].PublicDnsName");
do
#ssh -fn ec2-user@$inst "killall java"
ssh -i $KEYPATH -fn ec2-user@$inst "docker stop simrunner && docker rm simrunner"
done

echo "Simrunner stopped"