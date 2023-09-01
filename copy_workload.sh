source config.sh

export AWS_PAGER=""


res=$(aws ec2 describe-instances --filters "Name=tag:owner,Values=$OWNERTAG" "Name=tag:Name,Values=$NAMETAG" "Name=instance-state-name,Values=running")
echo "Public DNS names:"
echo $res | jq -r ".Reservations[].Instances[].PublicDnsName"
echo ""
echo "Public IP addresses:"
echo $res | jq -r ".Reservations[].Instances[].PublicIpAddress"

if [ -n "$1" ]; then
    echo "scp'ing $1 to hosts"
    for dns in $(echo $res | jq -r ".Reservations[].Instances[].PublicDnsName");
    do
      scp $1 $dns:workload.json
    done
fi
