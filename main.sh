#!/bin/bash
echo "Testing bash scripting"



# Read the file line by line
while IFS= read -r line; do
    PatientID=$(echo "$line" | cut -d":" -f1 | xargs)
    TestName=$(echo "$line" | cut -d":" -f2 | cut -d"," -f1 | xargs)
    Testdate=$(echo "$line" | cut -d":" -f2 | cut -d"," -f2 | xargs)
    PatientResult=$(echo "$line" | cut -d":" -f2 | cut -d"," -f3 | xargs)
    Testunit=$(echo "$line" | cut -d":" -f2 | cut -d"," -f4 | xargs)
    Teststatus=$(echo "$line" | cut -d":" -f2 | cut -d"," -f5 | xargs)

done < medicalRecord.txt


readMedicalTests(){

    while IFS= read -r line; do
    symbol=$(echo "$line" | cut -d";" -f1 | cut -d"(" -f2 | cut -d")" -f1 | xargs)
    TestName=$(echo "$line" | cut -d";" -f1 | cut -d"(" -f1 | xargs)
    upperRange=$(echo "$line" | cut -d";" -f2 | cut -d":" -f2 | cut -d"<" -f2 | xargs)
    lowerRange=$(echo "$line" | cut -d":" -f2 | cut -d"," -f3 | xargs)
    Testunit=$(echo "$line" | cut -d":" -f2 | cut -d"," -f4 | xargs)

    # Declare an associative array for the person
    

    # Serialize the associative array and store it in the main records array
done < medicalTest.txt

}
menu(){
    echo -e "\n  ==Welcome to the Medical Test Managment System== "
    echo "  choose an operation by number:"
    echo " 1- Add a new medical test record"
    echo " 2- search for a patient by ID"
    echo " 3- search for abnormal tests for a test type"
    echo " 4- find average test value for a test type"
    echo " 5- Update a test"
    echo " 6- Print All"
    echo " 7- exit"
}

Add(){ # Handeling !!!!!

    # while [ 0 -eq 0 ]
    # do 
    printf "\nEnter Patient ID: "
    read Id
    # if [ echo $Id | wc -c -eq 7 ]
    # then
    #     break
    # fi
    # printf("\n Invalid ID")
    #done
    printf "\nEnter Test Name: "
    read Name
    printf "\nEnter Date: "
    read Date
    printf "\nEnter result with unit: "
    read Result
    printf "\nEnter status: "
    read Status

    echo -e "\n$Id:$Name,$Date,$Result,$Status" >> medicalRecord.txt
    printf "record has been added successfully"

}

Avg(){
    while IFS= read -r line || [ -n "$line" ]; do
        symbol=$(echo "$line" | cut -d";" -f1 | cut -d"(" -f2 | cut -d")" -f1 | xargs)
        sum=0
        count=0
        grep $symbol medicalRecord.txt > temp.txt
        while IFS= read -r record; do
            PatientResult=$(echo "$record" | cut -d":" -f2 | cut -d"," -f3 | xargs)
            sum=$(echo "$sum + $PatientResult" | bc)
            count=$(($count+1))
        done < temp.txt
        if [ "$count" -gt 0 ]; then
            avg=$(echo "scale=2; $sum / $count" | bc)  #  bc for floating-point division, scale for decimal fractions
            echo -e "\nThe average for $symbol is $avg"
        else
            echo -e "\nNo records found for $symbol, cannot compute average."
        fi
    done < medicalTest.txt
}

update(){
    printf "\n enter patient ID: "
    read id
    grep  $id medicalRecord.txt > temp.txt
    printf "\n available tests are:\n"
    cat -n temp.txt
    printf "\n choose a test: "
    read choice
    record=$(sed -n "${choice}p" temp.txt)
    echo "$record" > temp.txt
    printf "\n Enter new result: "
    read newresult
    result=$(echo "$record" | cut -d":" -f2 | cut -d"," -f3 | xargs)
    newrecord=$(sed "s/$result/$newresult/g" temp.txt)
   #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # Update the record in medicalRecord.txt
    sed -i "s/$result_escaped/$newresult_escaped/" medicalRecord.txt

    #cat temp.txt > medicalRecord.txt
}

##### code starts
while [ 0 -eq 0 ]
do
    menu
    read x
    case $x in
        "1")
        Add
        sleep 3
        ;;
        "2")
        ;;
        "3")
        ;;
        "4")
        Avg
        sleep 3
        ;;
        "5")
        update
        sleep 2
        ;;
        "6")
            cat medicalRecord.txt
            echo ""
            sleep 3
            ;;
        "7") exit
        ;;
        *)
        echo " invalid option !!";;
    esac

done



