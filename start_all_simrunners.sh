source config.sh

export AWS_PAGER=""

res=$(aws ec2 describe-instances --filters "Name=tag:owner,Values=$OWNERTAG" "Name=tag:Name,Values=$NAMETAG" "Name=instance-state-name,Values=running")
echo "Public DNS names:"
echo $res | jq -r ".Reservations[].Instances[].PublicDnsName"

#if [ -n "$1" ]; then
#    echo "Starting workload $1 on hosts"
#else
#    echo "Usage: start_all_simrunners.sh <filename> (file must already be present on all hosts)"
#    exit -1
#fi

for inst in $(echo $res | jq -r ".Reservations[].Instances[].PublicDnsName");
do
#ssh -fn ec2-user@$inst "nohup java -jar /home/ec2-user/SimRunner.jar $1 > simrunner.log 2>&1"
#ssh -fn ec2-user@$inst "nohup java -jar /home/ec2-user/SimRunner.jar workload.json > simrunner.log 2>&1"
ssh -i $KEYPATH -fn ec2-user@$inst "docker run -p 3000:3000 --name simrunner -d -it --mount type=bind,source=/home/ec2-user/workload.json,target=/config.json sylvainchambon/simrunner:latest"
done

echo "Simrunner started"
