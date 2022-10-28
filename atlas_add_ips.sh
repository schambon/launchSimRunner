source config.sh

export AWS_PAGER=""

expiry=$(date -v+6H -u +"%Y-%m-%dT%H:%M:%SZ")
payload=$(aws ec2 describe-instances --filters "Name=tag:owner,Values=$OWNERTAG" "Name=tag:Name,Values=$NAMETAG" "Name=instance-state-name,Values=running" | jq -r "[ .Reservations[].Instances[] | {\"ipAddress\":.PublicIpAddress, \"deleteAfterDate\":\"$expiry\", \"comment\":\"SimRunner auto-added\"} ]")

curl --digest --user "$ATLASAPIKEY:$ATLASAPIPRIVKEY" -X POST --header "Content-Type: application/json" --header "Accept: application/json" -d "$payload" https://cloud.mongodb.com/api/atlas/v1.0/groups/$ATLASGROUP/accessList
