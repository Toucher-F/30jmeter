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
        CASENAME=${CASETYPE}-30preprod3-${CONCURRENCY}.jmx
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
ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.214.115 "sudo touch /storage/app1-top-${DIRNAME} && sudo chmod -Rf 777 /storage/app1-top-${DIRNAME} && sudo nohup top -u 1 -b > /storage/app1-top-${DIRNAME} & " &
ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.215.4 "sudo touch /storage/app2-top-${DIRNAME} && sudo chmod -Rf 777 /storage/app2-top-${DIRNAME} && sudo nohup top -u 1 -b > /storage/app2-top-${DIRNAME} & " &
ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.217.107 "sudo touch /storage/pg-top-${DIRNAME} && sudo chmod -Rf 777 /storage/pg-top-${DIRNAME} && sudo nohup top -u 1 -b > /storage/pg-top-${DIRNAME} & " &
ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.103.31 "sudo touch /storage/anly1-top-${DIRNAME} && sudo chmod -Rf 777 /storage/anly1-top-${DIRNAME} && sudo nohup top -u 1 -b > /storage/anly1-top-${DIRNAME} & " &
ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.21.235 "sudo touch /storage/anly2-top-${DIRNAME} && sudo chmod -Rf 777 /storage/anly2-top-${DIRNAME} && sudo nohup top -u 1 -b > /storage/anly2-top-${DIRNAME} & " &
ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.110.180 "sudo touch /storage/anlypg-top-${DIRNAME} && sudo chmod -Rf 777 /storage/anlypg-top-${DIRNAME} && sudo nohup top -u 1 -b > /storage/anlypg-top-${DIRNAME} & " &



ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.214.115 "sudo touch /storage/app1-io-${DIRNAME} && sudo chmod -Rf 777 /storage/app1-io-${DIRNAME} && sudo iostat 3 -x > /storage/app1-io-${DIRNAME} & " &
ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.215.4 "sudo touch /storage/app2-io-${DIRNAME} && sudo chmod -Rf 777 /storage/app2-io-${DIRNAME} && sudo iostat 3 -x > /storage/app2-io-${DIRNAME} & " &
ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.217.107 "sudo touch /storage/pg-io-${DIRNAME} && sudo chmod -Rf 777 /storage/pg-io-${DIRNAME} && sudo iostat 3 -x > /storage/pg-io-${DIRNAME} & " &
ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.103.31 "sudo touch /storage/anly1-io-${DIRNAME} && sudo chmod -Rf 777 /storage/anly1-io-${DIRNAME} && sudo iostat 3 -x > /storage/anly1-io-${DIRNAME} & " &
ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.21.235 "sudo touch /storage/anly2-io-${DIRNAME} && sudo chmod -Rf 777 /storage/anly2-io-${DIRNAME} && sudo iostat 3 -x > /storage/anly2-io-${DIRNAME} & " &
ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.110.180 "sudo touch /storage/anlypg-io-${DIRNAME} && sudo chmod -Rf 777 /storage/anlypg-io-${DIRNAME} && sudo iostat 3 -x > /storage/anlypg-io-${DIRNAME} & " &


echo "------------------running test case-----------------"

#scp -r root@138.197.132.140:/jmeter/apache-jmeter-3.1/bin/${CASENAME} /jmeter/apache-jmeter-3.1/bin/
cd /jmeter/apache-jmeter-3.1/bin && sudo ./jmeter -n -t $CASENAME -l /30jmeter/${DIRNAME}/${DIRNAME}.csv

echo "------------------terminating top proccess-----------------"
#ps -ef | grep top | grep -v grep | awk  '{print $2}' |  awk '{for(i=0;++i<=NF;)a[i]=a[i]?a[i] FS $i:$i}END{for(i=0;i++<NF;)print a[i]}'
#APP1TOP=$(ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.214.115   "ps -ef | grep 'top -u 1 -b' | grep -v grep | grep -v nohup | grep -v bash | awk  '{print $2}'"| awk '{print $2}')
#ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.214.115 "sudo kill -9 ${APP1TOP}"
#APP2TOP=$(ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.215.4   "ps -ef | grep 'top -u 1 -b' | grep -v grep | grep -v nohup | grep -v bash | awk  '{print $2}'"| awk '{print $2}')
#ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.215.4 "sudo kill -9 ${APP2TOP}"
#PGTOP=$(ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.217.107   "ps -ef | grep 'top -u 1 -b' | grep -v grep | grep -v nohup | grep -v bash | awk  '{print $2}'"| awk '{print $2}')
#ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.217.107 "sudo kill -9 ${PGTOP}"
#ANLY1TOP=$(ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.103.31   "ps -ef | grep 'top -u 1 -b' | grep -v grep | grep -v nohup | grep -v bash | awk  '{print $2}'"| awk '{print $2}')
#ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.103.31 "sudo kill -9 ${ANLY1TOP}"
#ANLY2TOP=$(ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.21.235   "ps -ef | grep 'top -u 1 -b' | grep -v grep | grep -v nohup | grep -v bash | awk  '{print $2}'"| awk '{print $2}')
#ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.21.235 "sudo kill -9 ${ANLY2TOP}"
#ANLYPGTOP=$(ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.110.180   "ps -ef | grep 'top -u 1 -b' | grep -v grep | grep -v nohup | grep -v bash | awk  '{print $2}'"| awk '{print $2}')
#ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.110.180 "sudo kill -9 ${ANLYPGTOP}"



APP1TOP=$(ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.214.115 "sudo killall top")
APP2TOP=$(ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.215.4 "sudo killall top")
PGTOP=$(ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.217.107 "sudo killall top")
ANLY1TOP=$(ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.103.31 "sudo killall top")
ANLY2TOP=$(ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.21.235 "sudo killall top")
ANLYPGTOP=$(ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.110.180 "sudo killall top")

echo "------------------terminating iostat proccess-----------------"

#APP1IO=$(ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.214.115 "ps -ef | grep 'iostat' | grep -v grep | grep -v sudo | grep -v bash | awk  '{print $2}'"| awk '{print $2}')
#ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.214.115 "sudo kill -9 ${APP1IO}"
#APP2IO=$(ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.215.4 "ps -ef | grep 'iostat' | grep -v grep | grep -v sudo | grep -v bash | awk  '{print $2}'"| awk '{print $2}')
#ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.215.4 "sudo kill -9 ${APP2IO}"
#PGIO=$(ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.217.107 "ps -ef | grep 'iostat' | grep -v grep | grep -v sudo | grep -v bash | awk  '{print $2}'"| awk '{print $2}')
#ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.217.107 "sudo kill -9 ${PGIO}"
#ANLY1IO=$(ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.103.31 "ps -ef | grep 'iostat' | grep -v grep | grep -v sudo | grep -v bash | awk  '{print $2}'"| awk '{print $2}')
#ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.103.31 "sudo kill -9 ${ANLY1IO}"
#ANLY2IO=$(ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.21.235 "ps -ef | grep 'iostat' | grep -v grep | grep -v sudo | grep -v bash | awk  '{print $2}'"| awk '{print $2}')
#ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.21.235 "sudo kill -9 ${ANLY2IO}"
#ANLYPGIO=$(ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.110.180 "ps -ef | grep 'iostat' | grep -v grep | grep -v sudo | grep -v bash | awk  '{print $2}'"| awk '{print $2}')
#ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.110.180 "sudo kill -9 ${ANLYPGIO}"

APP1IO=$(ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.214.115 "sudo killall iostat")
APP2IO=$(ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.215.4 "sudo killall iostat")
PGIO=$(ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.217.107 "sudo killall iostat")
ANLY1IO=$(ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.103.31 "sudo killall iostat")
ANLY2IO=$(ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.21.235 "sudo killall iostat")
ANLYPGIO=$(ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.110.180 "sudo killall iostat")


echo "------------------copying file-----------------"

scp -i /storage/dealtap.pem -r ubuntu@35.182.214.115:/storage/app1-top-${DIRNAME} /30jmeter/${DIRNAME}/
scp -i /storage/dealtap.pem -r ubuntu@35.182.215.4:/storage/app2-top-${DIRNAME} /30jmeter/${DIRNAME}/
scp -i /storage/dealtap.pem -r ubuntu@35.182.217.107:/storage/pg-top-${DIRNAME} /30jmeter/${DIRNAME}/
scp -i /storage/dealtap.pem -r ubuntu@35.182.103.31:/storage/anly1-top-${DIRNAME} /30jmeter/${DIRNAME}/
scp -i /storage/dealtap.pem -r ubuntu@35.182.21.235:/storage/anly2-top-${DIRNAME} /30jmeter/${DIRNAME}/
scp -i /storage/dealtap.pem -r ubuntu@35.182.110.180:/storage/anlypg-top-${DIRNAME} /30jmeter/${DIRNAME}/

scp -i /storage/dealtap.pem -r ubuntu@35.182.214.115:/storage/app1-io-${DIRNAME} /30jmeter/${DIRNAME}/
scp -i /storage/dealtap.pem -r ubuntu@35.182.215.4:/storage/app2-io-${DIRNAME} /30jmeter/${DIRNAME}/
scp -i /storage/dealtap.pem -r ubuntu@35.182.217.107:/storage/pg-io-${DIRNAME} /30jmeter/${DIRNAME}/
scp -i /storage/dealtap.pem -r ubuntu@35.182.103.31:/storage/anly1-io-${DIRNAME} /30jmeter/${DIRNAME}/
scp -i /storage/dealtap.pem -r ubuntu@35.182.21.235:/storage/anly2-io-${DIRNAME} /30jmeter/${DIRNAME}/
scp -i /storage/dealtap.pem -r ubuntu@35.182.110.180:/storage/anlypg-io-${DIRNAME} /30jmeter/${DIRNAME}/

ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.214.115 "sudo rm /storage/app1-top-${DIRNAME}"
ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.215.4 "sudo rm /storage/app2-top-${DIRNAME}"
ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.217.107 "sudo rm /storage/pg-top-${DIRNAME}"
ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.103.31 "sudo rm /storage/anly1-top-${DIRNAME}"
ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.21.235 "sudo rm /storage/anly2-top-${DIRNAME}"
ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.110.180 "sudo rm /storage/anlypg-top-${DIRNAME}"

ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.214.115 "sudo rm /storage/app1-io-${DIRNAME}"
ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.215.4 "sudo rm /storage/app2-io-${DIRNAME}"
ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.217.107 "sudo rm /storage/pg-io-${DIRNAME}"
ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.103.31 "sudo rm /storage/anly1-io-${DIRNAME}"
ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.21.235 "sudo rm /storage/anly2-io-${DIRNAME}"
ssh -o StrictHostKeyChecking=no -i /storage/dealtap.pem ubuntu@35.182.110.180 "sudo rm /storage/anlypg-io-${DIRNAME}"
FOLDERNAME=${DIRNAME}

DIRNAME2=$(echo ${FOLDERNAME} | cut -d . -f 1)

if [ ! -d /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/ ];then
    mkdir /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/
fi
echo "=====================app1 start===================="
top app1
echo "=====================app1 end===================="
#if [ -f "/30jmeter/${FOLDERNAME}/app2-top-${FOLDERNAME}" ];then
    echo "=====================app2 start===================="
    top app2
    echo "=====================app2 end===================="
#else
#    echo "=====================no app2===================="
#fi

echo "=====================pg start===================="
top pg
echo "=====================pg end===================="

echo "=====================anly1 start===================="
top anly1
echo "=====================anly1 end===================="

echo "=====================anly2 start===================="
top anly2
echo "=====================anly2 end===================="

echo "=====================anlypg start===================="
top anlypg
echo "=====================anlypg end===================="

#if [ -f "/30jmeter/${FOLDERNAME}/app2-top-${FOLDERNAME}" ];then
    cat /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/result-app1-top-${FOLDERNAME} /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/result-app2-top-${FOLDERNAME} /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/result-pg-top-${FOLDERNAME} /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/result-anly1-top-${FOLDERNAME} /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/result-anly2-top-${FOLDERNAME} /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/result-anlypg-top-${FOLDERNAME} > /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/result-final-${FOLDERNAME}
#else
#    cat /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/result-app1-top-${FOLDERNAME} /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/result-pg-top-${FOLDERNAME} > /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/result-final-${FOLDERNAME}
#fi
echo "=====================sending email===================="
echo "AWS CSV ${FOLDERNAME}, sent from jmeter server" | mail -s "AWS CSV ${FOLDERNAME}" -A /30jmeter/${FOLDERNAME}/${FOLDERNAME}.csv nancybingru@gmail.com
echo "AWS result ${FOLDERNAME}, sent from jmeter server" | mail -s "AWS result ${FOLDERNAME}" -A /30jmeter/${FOLDERNAME}/result_${FOLDERNAME}/result-final-${FOLDERNAME} nancybingru@gmail.com
echo "=====================moving file===================="
if [ ! -d "/30jmeter/history" ]; then
  mkdir /30jmeter/history
fi
mv /30jmeter/${DIRNAME} /30jmeter/history/
echo "--------------------end of cpujmeter.sh----------------"

