source config.sh

export AWS_PAGER=""

expiry=$(date -v+6H -u +"%Y-%m-%dT%H:%M:%SZ")
payload=$(aws ec2 describe-instances --filters "Name=tag:owner,Values=$OWNERTAG" "Name=tag:Name,Values=$NAMETAG" "Name=instance-state-name,Values=running" | jq "[ .Reservations[].Instances[] | (.PublicDnsName + \":3000\") ]")

echo $payload
