#!/bin/bash
declare -A person
declare -A records
#person=([name]="jone" [test]="LDL")
#echo "${person[@]}"
#records=([99]=$person)
for line in $(cat medicalRecord.txt)
do
    PatientID=$(echo "$line" | cut -d":" -f1 )
    TestName=$(echo "$line" | cut -d":" -f2 | cut -d"," -f1 )
    Testdate=$(echo "$line" | cut -d":" -f2 | cut -d"," -f2 )
    PatientResult=$(echo "$line" | cut -d":" -f2 | cut -d"," -f3 )
    Testunit=$(echo "$line" | cut -d":" -f2 | cut -d"," -f4 )
    Teststatus=$(echo "$line" | cut -d":" -f2 | cut -d"," -f5 )
    person=([name]=$TestName [date]=$Testdate [resutl]=$PatientResult [unit]=$Testunit [status]=$Teststatus)
    #echo "${person[name]} ${person[date]}"
    records=(["$PatientID"]="${person[@]}")
    
    
done 
for key in "${!records[@]}"
do 
echo "${records[$key]}"
done