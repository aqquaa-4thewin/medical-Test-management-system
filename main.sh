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
    upperRange=$(echo "$line" | sed -n 's/.*< \([0-9.]*\).*/\1/p')
    lowerRange=$(echo "$line" | sed -n 's/.*> \([0-9.]*\),.*/\1/p')
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

search_menu(){
    printf "\n 1-Retrieve all patient tests\n 2-Retrieve all up normal patient tests\n 3-Retrieve all patient tests in a given specific period\n 4-Retrieve all patient tests based on test status"
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
    grep -vF "$record" medicalRecord.txt > temp.txt
    echo "$newrecord" >> temp.txt
    printf "%s" "$(cat temp.txt)" > medicalRecord.txt # to remove new line with copy
}

search_id(){
    printf "\n enter patient ID: "
    read id
    search_menu
    printf "\n choose an option:  "
    read  choice
    case $choice in
        "1")
        print_by_ID "$id"
        ;;
        "2")
        ;;
        "3")
        print_in_period "$id"
        ;;
        "4")
        print_by_status "$id"
        ;;
        *)
        echo " invalid option !!";;
    esac

}
print_by_ID(){
    id=$1
    printf "\n Patient tests are:\n"
    grep  "$id" medicalRecord.txt 
    

}
print_by_status(){
    id=$1
    grep  $id medicalRecord.txt > temp.txt
    printf '\n Enter status: (Pending", Completed, Reviewed)'
    read status
    grep "$status" temp.txt
    

}

print_in_period(){
    id=$1
    grep  $id medicalRecord.txt > temp.txt
    printf "\n Enter first Date: "
    read DateFrom
    YFrom=$(echo "$DateFrom" | cut -d"-" -f1)
    MFrom=$(echo "$DateFrom" | cut -d"-" -f2)

    printf "\n Enter second Date: "
    read DateTo
    YTo=$(echo "$DateTo" | cut -d"-" -f1)
    MTo=$(echo "$DateTo" | cut -d"-" -f2)
    printf "\n"


    while IFS= read -r line; do
        Y=$(echo "$line" | cut -d":" -f2 | cut -d"," -f2 | xargs | cut -d"-" -f1)
        M=$(echo "$line" | cut -d":" -f2 | cut -d"," -f2 | xargs | cut -d"-" -f2)
         if [ "$Y" -lt "$YFrom" ] || [ "$Y" -gt "$YTo" ] ||
           { [ "$Y" -eq "$YFrom" ] && [ "$M" -lt "$MFrom" ]; } ||
           { [ "$Y" -eq "$YTo" ] && [ "$M" -gt "$MTo" ]; }; then
            continue
        fi

        echo "$line"


    done < temp.txt



}

##### code starts
while [ 0 -eq 0 ]
do
    menu
    read x
    case $x in
        "1")
        Add
        sleep 2
        ;;
        "2")
        search_id
        sleep 2
        ;;
        "3")
        ;;
        "4")
        Avg
        sleep 2
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



