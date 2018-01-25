#!/bin bash

function top
{
    grep load /30jmeter/${FOLDERNAME}/${1}-top-${FOLDERNAME} | awk  '{print $3 "\t" $10"\t" $11"\t" $12}' > /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/top1
    if grep -niwq "load" /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/top1; then
        rm /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/top1
        grep load /30jmeter/${FOLDERNAME}/${1}-top-${FOLDERNAME} | awk  '{print $3 "\t" $12"\t" $13"\t" $14}' > /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/top1
    fi
    grep Tasks /30jmeter/${FOLDERNAME}/${1}-top-${FOLDERNAME} | awk  '{print $4}' > /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/top2
    grep Cpu /30jmeter/${FOLDERNAME}/${1}-top-${FOLDERNAME}  > /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/top3
    awk '{for(i=2;i<=NF;i=i+2) printf"%s ",$i} {print ""}' /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/top3 > /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/top4
    grep cache /30jmeter/${FOLDERNAME}/${1}-top-${FOLDERNAME} | awk  '{print $4 "\t" $6"\t"}' > /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/top5
    grep vda /30jmeter/${FOLDERNAME}/${1}-io-${FOLDERNAME} | awk '{print $9 "\t" $10"\t" $13"\t" $14}' > /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/io1
    paste /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/top1 /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/top2 /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/top4 /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/top5 /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/io1 > /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/result-${1}-top-${FOLDERNAME}
    sed -i 's/^/'${CONCURRENCY}' '${1}' &/g' /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/result-${1}-top-${FOLDERNAME}
    #sed -i 's/$/&'${DIRNAME}'/g' /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/result-app1-top-${FOLDERNAME}
    sed -i '1i\Concurrency server time LOADavg1m LOADavg5m LOADavg15m Tasks us sy ni id wa hi si st MEMtotal MEMfree avgqu-sz await svctm util' /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/result-${1}-top-${FOLDERNAME}
    rm /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/top* /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/io*
}

read -p "Please input the case type[api/full/other]?" CASETYPE
if [ -z ${CASETYPE} ];then
	echo "The case type cannot be null"
	exit 1
fi
arr=(api full)
arr2=(other)
if
	echo ${arr[@]} | grep -wq ${CASETYPE}
then
    read -p "Please input the project concurrency?" CONCURRENCY
    if [ -z ${CONCURRENCY} ];then
	    echo "The concurrency cannot be null"
	    exit 1
    else
        CASENAME=${CASETYPE}-30prod-${CONCURRENCY}.jmx
    fi
elif
	echo ${arr2[@]} | grep -wq ${CASETYPE}
then
    read -p "Please input the case name?" CASENAME
    if [ -z ${CASENAME} ];then
	echo "The case name cannot be null"
	exit 1
    fi
    read -p "Please input the project concurrency?" CONCURRENCY
    if [ -z ${CONCURRENCY} ];then
	    echo "The concurrency cannot be null"
	    exit 1
    fi
else
    echo "invalid case type"
	exit 1
fi

if [ ! -f "/jmeter/apache-jmeter-3.1/bin/${CASENAME}" ]; then
    echo "invalid case name"
	exit 1
else
    echo "" >/dev/null
fi

DIRNAME=${CASENAME}_$(date +"%Y%m%d%H%M%S")
mkdir /30jmeter/${DIRNAME}

echo "------------------creating log file-----------------"
ssh -o StrictHostKeyChecking=no root@10.136.59.191 "touch /storage/app1-top-${DIRNAME} && nohup top -u 1 -b > /storage/app1-top-${DIRNAME} & " &
#ssh -o StrictHostKeyChecking=no root@10.137.144.173 "touch /storage/app2-top-${DIRNAME} && nohup top -u 1 -b > /storage/app2-top-${DIRNAME} &" &
ssh -o StrictHostKeyChecking=no root@10.136.34.214 "touch /storage/pg-top-${DIRNAME} && nohup top -u 1 -b > /storage/pg-top-${DIRNAME} & " &

ssh -o StrictHostKeyChecking=no root@10.136.59.191 "touch /storage/app1-io-${DIRNAME} && iostat 3 -x > /storage/app1-io-${DIRNAME} & " &
#ssh -o StrictHostKeyChecking=no root@10.137.144.173 "touch /storage/app2-io-${DIRNAME} && iostat 3 -x > /storage/app2-io-${DIRNAME} &" &
ssh -o StrictHostKeyChecking=no root@10.136.34.214 "touch /storage/pg-io-${DIRNAME} && iostat 3 -x > /storage/pg-io-${DIRNAME} & " &

echo "------------------running test case-----------------"


cd /jmeter/apache-jmeter-3.1/bin && ./jmeter -n -t $CASENAME -l /30jmeter/${DIRNAME}/${DIRNAME}.csv

echo "------------------terminating top proccess-----------------"


APP1TOP=$(ssh -o StrictHostKeyChecking=no root@10.136.59.191 "ps -ef | grep "top" | grep -v "grep" | awk '{print \$2}' | xargs kill -9")
#APP2TOP=$(ssh -o StrictHostKeyChecking=no root@10.137.144.173 "ps -ef | grep "top" | grep -v "grep" | awk '{print \$2}' | xargs kill -9")
PGTOP=$(ssh -o StrictHostKeyChecking=no root@10.136.34.214 "ps -ef | grep "top" | grep -v "grep" | awk '{print \$2}' | xargs kill -9")

echo "------------------terminating iostat proccess-----------------"
APP1TOP=$(ssh -o StrictHostKeyChecking=no root@10.136.59.191 "ps -ef | grep "iostat" | grep -v "grep" | awk '{print \$2}' | xargs kill -9")
#APP2TOP=$(ssh -o StrictHostKeyChecking=no root@10.137.144.173 "ps -ef | grep "iostat" | grep -v "grep" | awk '{print \$2}' | xargs kill -9")
PGTOP=$(ssh -o StrictHostKeyChecking=no root@10.136.34.214 "ps -ef | grep "iostat" | grep -v "grep" | awk '{print \$2}' | xargs kill -9")


echo "------------------copying file-----------------"

scp -r root@10.136.59.191:/storage/app1-top-${DIRNAME} /30jmeter/${DIRNAME}/
#scp -r root@10.137.144.173:/storage/app2-top-${DIRNAME} /30jmeter/${DIRNAME}/
scp -r root@10.136.34.214:/storage/pg-top-${DIRNAME} /30jmeter/${DIRNAME}/

scp -r root@10.136.59.191:/storage/app1-io-${DIRNAME} /30jmeter/${DIRNAME}/
#scp -r root@10.137.144.173:/storage/app2-io-${DIRNAME} /30jmeter/${DIRNAME}/
scp -r root@10.136.34.214:/storage/pg-io-${DIRNAME} /30jmeter/${DIRNAME}/

ssh -o StrictHostKeyChecking=no root@10.136.59.191 "rm /storage/app1-top-${DIRNAME}"
#ssh -o StrictHostKeyChecking=no root@10.137.144.173 "rm /storage/app2-top-${DIRNAME}"
ssh -o StrictHostKeyChecking=no root@10.136.34.214 "rm /storage/pg-top-${DIRNAME}"

ssh -o StrictHostKeyChecking=no root@10.136.59.191 "rm /storage/app1-io-${DIRNAME}"
#ssh -o StrictHostKeyChecking=no root@10.137.144.173 "rm /storage/app2-io-${DIRNAME}"
ssh -o StrictHostKeyChecking=no root@10.136.34.214 "rm /storage/pg-io-${DIRNAME}"


FOLDERNAME=${DIRNAME}

DIRNAME2=$(echo ${FOLDERNAME} | cut -d . -f 1)

if [ ! -d /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/ ];then
    mkdir /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/
fi
echo "=====================app1 start===================="
top app1
echo "=====================app1 end===================="
if [ -f "/30jmeter/${FOLDERNAME}/app2-top-${FOLDERNAME}" ];then
    echo "=====================app2 start===================="
    top app2
    echo "=====================app2 end===================="
else
    echo "=====================no app2===================="
fi

echo "=====================pg start===================="
top pg
echo "=====================pg end===================="

if [ -f "/30jmeter/${FOLDERNAME}/app2-top-${FOLDERNAME}" ];then
    cat /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/result-app1-top-${FOLDERNAME} /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/result-app2-top-${FOLDERNAME} /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/result-pg-top-${FOLDERNAME} > /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/result-final-${FOLDERNAME}
else
    cat /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/result-app1-top-${FOLDERNAME} /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/result-pg-top-${FOLDERNAME} > /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/result-final-${FOLDERNAME}
fi
echo "=====================sending email===================="
echo "30prod CSV ${FOLDERNAME}, sent from jmeter server" | mail -s "30prod CSV ${FOLDERNAME}" -A /30jmeter/${FOLDERNAME}/${FOLDERNAME}.csv nancy.zhang@saninco.com
echo "30prod result ${FOLDERNAME}, sent from jmeter server" | mail -s "30prod result ${FOLDERNAME}" -A /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/result-final-${FOLDERNAME} nancy.zhang@saninco.com
echo "=====================moving file===================="
if [ ! -d "/30jmeter/history" ]; then
  mkdir /30jmeter/history
fi
mv /30jmeter/${DIRNAME} /30jmeter/history/
echo "--------------------end of cpujmeter.sh----------------"