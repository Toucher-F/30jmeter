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


read -p "Please input the folder name?" FOLDERNAME
if [ -z ${FOLDERNAME} ];then
	echo "The case type cannot be null"
	exit 1
fi
if [ ! -d /30jmeter/${FOLDERNAME} ];then
	echo "Folder doesn't exist"
	exit 1
fi


DIRNAME2=$(echo ${FOLDERNAME} | cut -d . -f 1)
CONCURRENCY=$(echo ${DIRNAME2} | cut -d - -f 3)
#echo "${CONCURRENCY}"


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
mv /30jmeter/${FOLDERNAME} /30jmeter/history/
echo "--------------------end of 30prodjmeter.sh----------------"