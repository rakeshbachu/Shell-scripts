#!/bin/bash
BLUE='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'
alrexpcmp=()
alrexpcer=()
abtexpcmp=()
abtexpcer=()

arr=(`ls | grep _`)

#echo ${arr}

for i in "${arr[@]}"
do
        #echo "$i"

        `cat -v <<path to the folders of xmlfiles>>/$i/idp.xml | fgrep -q "^M"`
        if [ $? == '1' ]
        then
        echo "`tr -d '\n' < <<path to the folders of xmlfiles>>/$i/idp.xml | tr -d ' '| grep -oP -m 1 '(?<=Certificate>).*(?=</.*Certificate)'| awk -F "</" '{print $1}'`" > /usr/local/mycerts/$i.crt
        else
        echo "`tr -d '\r' < <<path to the folders of xmlfiles>>/$i/idp.xml | tr -d '\n' | tr -d ' ' | grep -oP -m 1 '(?<=Certificate>).*(?=</.*Certificate)'| awk -F "</" '{print $1}'`" > /usr/local/mycerts/$i.crt
        fi
done

for j in "${arr[@]}"
do
        echo -e "processing ${BLUE} $j ${NC}"
        echo -e "-----BEGIN CERTIFICATE-----" > /usr/local/mycerts/$j-final.crt
        echo "`fold -w 64 /usr/local/mycerts/$j.crt`" >> /usr/local/mycerts/$j-final.crt
        echo -e "-----END CERTIFICATE-----" >> /usr/local/mycerts/$j-final.crt
        dat=`openssl x509 -enddate -noout -in /usr/local/mycerts/$j-final.crt | awk -F "=" '{print $2}'`
        if [ -z "$dat" ] 
        then
                echo "cannot load certificate for $j"
                continue
        else
        echo -e  "${GREEN}${dat} ${NC}"
        ndat=`date -d "${dat}" +%s`
        echo $ndat
        curdate=`date +%s`
        diffdate=$((ndat-curdate))
        echo $diffdate
        fi
        if [ $ndat -lt $curdate ]
        then
                alrexpcmp+=("$j")
                alrexpcer+=("$dat")
        elif [ $diffdate -lt "604800" ]
        then
                abtexpcmp+=("$j")
                abtexpcer+=("$dat")
        fi

done

echo ${alrexpcmp[@]}
echo ${alrexpcer[@]}

echo ${abtexpcmp[@]}
echo ${abtexpcer[@]}

output=()
output0=`echo "The Companies which certificates are already expired are as follows"`
if [ ${#alrexpcmp[@]} -gt 0 ]
then
for (( k=0; k<${#alrexpcmp[@]}; k++ ))
do
        output+=(`echo -e "company ${alrexpcmp[$k]} certificate expired on ${alrexpcer[$k]} ^ "`)
done

output1=`echo ${output[@]} | tr "^" "\n"`
else
output1=`echo "NONE"`
fi

output2=`echo "the certificates which are due expiry in next 7 days are as follows"`

if [ ${#abtexpcmp[@]} -gt 0 ]
then
opab=()
for (( k=0; k<${#abtexpcmp[@]}; k++ ))
do
        opab+=(`echo -e "company ${abtexpcmp[$k]} certificate is going to  expire on ${abtexpcer[$k]} ^ "`)
done

opab1=`echo ${opab[@]} | tr "^" "\n"`
echo -e " $output0 \n\n $output1 \n\n\n\n $output2 \n\n $opab1" | mailx -s "Certificate status" "<<your mail id>>"
else
echo -e " $output0 \n\n $output1 \n\n\n\n $output2 \n\n NONE" | mailx -s "Certificate status" "<<your mail id>>"

fi

#echo $output3
