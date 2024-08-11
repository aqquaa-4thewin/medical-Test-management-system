#!/bin/bash




# Read the file line by line
# while IFS= read -r line; do
#     PatientID=$(echo "$line" | cut -d":" -f1 | xargs)
#     TestName=$(echo "$line" | cut -d":" -f2 | cut -d"," -f1 | xargs)
#     Testdate=$(echo "$line" | cut -d":" -f2 | cut -d"," -f2 | xargs)
#     PatientResult=$(echo "$line" | cut -d":" -f2 | cut -d"," -f3 | xargs)
#     Testunit=$(echo "$line" | cut -d":" -f2 | cut -d"," -f4 | xargs)
#     Teststatus=$(echo "$line" | cut -d":" -f2 | cut -d"," -f5 | xargs)

# done < medicalRecord.txt



# readMedicalTests(){

#     while IFS= read -r line; do
#     symbol=$(echo "$line" | cut -d";" -f1 | cut -d"(" -f2 | cut -d")" -f1 | xargs)
#     TestName=$(echo "$line" | cut -d";" -f1 | cut -d"(" -f1 | xargs)
#     upperRange=$(echo "$line" | sed -n 's/.*< \([0-9.]*\).*/\1/p')
#     lowerRange=$(echo "$line" | sed -n 's/.*> \([0-9.]*\),.*/\1/p')
#     Testunit=$(echo "$line" | cut -d":" -f2 | cut -d"," -f4 | xargs)

#     # Declare an associative array for the person
    

#     # Serialize the associative array and store it in the main records array
# done < medicalTest.txt

# }


declare -A normal_ranges 

# Read the test ranges from the file and populate the associative array
while IFS= read -r line || [ -n "$line" ]; do
    # Extract test name
    test_name=$(echo "$line" | grep -oP '(?<=\().*(?=\))' |  tr '[:upper:]' '[:lower:]')
    
    # Extract range
    range=$(echo "$line" | grep -oP '(?<=Range: ).*(?=; Unit)')
    
    lower_limit=$(echo "$range" | grep -oP '(?<=\> )[^,]*' | xargs)
    upper_limit=$(echo "$range" | grep -oP '(?<=< )[^,]*' | xargs)

    if [ -z "$lower_limit" ]; then
        lower_limit=0
    fi

    if [ -z "$upper_limit" ]; then
        upper_limit=9999  # large value 
    fi

    normal_ranges["$test_name"]="$lower_limit $upper_limit"
done < medicalTest.txt





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

Add(){ # Add a medical test

    while [ 0 -eq 0 ]
    do 
    printf "\nEnter Patient ID: "
    read Id
    check_Id $Id
    status=$?
        if [ $status -eq 0 ]
        then 
            break
        fi 
    done

    while [ 0 -eq 0 ]
    do 
    printf "\nEnter Test Name: "
    read Name
    check_name $Name
    status=$?
        if [ $status -eq 0 ]
        then 
            break
        fi 
    done
    
    while [ 0 -eq 0 ]
    do 
    printf "\nEnter Date: "
    read Date
    check_date $Date
    status=$?
        if [ $status -eq 0 ]
        then 
            break
        fi 
    done
    
    while [ 0 -eq 0 ]
    do 
    printf "\nEnter result: "
    read Result
    check_result $Result
    status=$?
        if [ $status -eq 0 ]
        then 
            break
        fi 
    done

    while [ 0 -eq 0 ]
    do 
    printf "\nEnter status ( Pending ,  Completed ,  Reviewed ): "
    read Status
    check_status $Status
    status=$?
        if [ $status -eq 0 ]
        then 
            break
        fi 
    done

    unit=$(grep -i "$Name" medicalTest.txt | cut -d":" -f4 | xargs) # -i greps regardless of upper or lower cases

    #echo -e "\n$Id:$Name,$Date,$Result,$unit,$Status" >> medicalRecord.txt
    printf "%s" "$(echo -e "\n$Id:$Name,$Date,$Result,$unit,$Status")" >> medicalRecord.txt # to remove new line with copy
    printf "  record has been added successfully"

}

Avg(){
    while IFS= read -r line || [ -n "$line" ]; do
        symbol=$(echo "$line" | cut -d";" -f1 | cut -d"(" -f2 | cut -d")" -f1 | xargs)
        sum=0
        count=0
        grep "$symbol" medicalRecord.txt > temp.txt
        while IFS= read -r record; do
            PatientResult=$(echo "$record" | cut -d":" -f2 | cut -d"," -f3 | xargs)
            sum=$(echo "$sum + $PatientResult" | bc)
            count=$(($count+1))
        done < temp.txt
        unit=$(grep -i "$symbol" medicalTest.txt | cut -d":" -f4 | xargs)
        if [ "$count" -gt 0 ]; then
            avg=$(echo "scale=2; $sum / $count" | bc)  #  bc for floating-point division, scale for decimal fractions
            echo -e "\nThe average for $symbol is $avg $unit"
        else
            echo -e "\nNo records found for $symbol, cannot compute average."
        fi
    done < medicalTest.txt
}

update(){
    while [ 0 -eq 0 ]
    do 
        printf "\n enter patient ID: "
        read id
        check_Id $id
        status=$?
        if [ $status -eq 0 ]
        then 
            break
        fi 
    done

    grep  $id medicalRecord.txt > temp.txt

    if [ ! -s temp.txt ] ; then # check if file is empty !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        echo -e "\n no records for patient $id "
        return
    fi

    printf "\n available tests are:\n"
    cat -n temp.txt
    while [ 0 -eq 0 ]
    do 
        printf "\n choose a test: "
        read choice
        if [ $choice -le "$(cat temp.txt | wc -l)" ] &&  [ $choice -gt 0 ]
        then
        break
        fi
        printf "\n Invalid Option"
    done

    record=$(sed -n "${choice}p" temp.txt)
    echo "$record" > temp.txt
    while [ 0 -eq 0 ]
    do 
    printf "\nEnter new result: "
    read newresult
    check_result $newresult
    status=$?
        if [ $status -eq 0 ]
        then 
            break
        fi 
    done

    result=$(echo "$record" | cut -d":" -f2 | cut -d"," -f3 | xargs)
    newrecord=$(sed "s/$result/$newresult/g" temp.txt)
    grep -vF "$record" medicalRecord.txt > temp.txt
    echo "$newrecord" >> temp.txt
    printf "%s" "$(cat temp.txt)" > medicalRecord.txt # to remove new line with copy
}

search_id(){
    while [ 0 -eq 0 ]
    do 
        printf "\n enter patient ID: "
        read id
        check_Id $id
        status=$?
        if [ $status -eq 0 ]
        then 
            break
        fi 
    done

    if ! grep -q "$id" medicalRecord.txt; then #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        echo "No matches found for $id"
        return
    fi

    search_menu

    while [ 0 -eq 0 ]
    do 
        printf "\n choose an option:  "
        read  choice
        case $choice in
            "1")
            print_by_ID "$id"
            break
            ;;
            "2")
            Abnormal_ID "$id"
            break
            ;;
            "3")
            print_in_period "$id"
            break
            ;;
            "4")
            print_by_status "$id"
            break
            ;;
            *)
            echo " invalid option !!";;
        esac
    done

}
print_by_ID(){
    id=$1
    printf "\n Patient tests are:\n"
    grep  "$id" medicalRecord.txt 
    

}


print_by_status(){
    id=$1
    grep  $id medicalRecord.txt > temp.txt
    while [ 0 -eq 0 ]
    do 
        printf "\nEnter status ( Pending ,  Completed ,  Reviewed ): "
        read status
        check_status $status
        stat=$?
            if [ $stat -eq 0 ]
            then 
                break
            fi 
    done

    if [ ! -s temp.txt ] ; then # check if file is empty
        echo -e "\n no records for patient $id with status $status"
        return
    fi
    grep "$status" temp.txt
    

}

print_in_period(){
    id=$1
    grep  $id medicalRecord.txt > temp.txt
    while [ 0 -eq 0 ]
    do 
        while [ 0 -eq 0 ]
        do 
            printf "\n Enter first Date: "
            read DateFrom
            check_date $DateFrom
            stat=$?
                if [ $stat -eq 0 ]
                then 
                    break
                fi 
        done

        YFrom=$(echo "$DateFrom" | cut -d"-" -f1)
        MFrom=$(echo "$DateFrom" | cut -d"-" -f2)

        while [ 0 -eq 0 ]
        do 
            printf "\n Enter second Date: "
            read DateTo
            stat=$?
                if [ $stat -eq 0 ]
                then 
                    break
                fi 
        done

        YTo=$(echo "$DateTo" | cut -d"-" -f1)
        MTo=$(echo "$DateTo" | cut -d"-" -f2)
        printf "\n"

        if [ "$YFrom" -gt "$YTo" ] || { [ "$YFrom" -eq "$YTo" ] && [ "$MFrom" -gt "$MTo" ]; }; then
            printf "\nEnter 'From' date that is earlier than 'To' date\n"
        else
            break
        fi
    done



    flag=1
    while IFS= read -r line; do
        Y=$(echo "$line" | cut -d":" -f2 | cut -d"," -f2 | xargs | cut -d"-" -f1)
        M=$(echo "$line" | cut -d":" -f2 | cut -d"," -f2 | xargs | cut -d"-" -f2)
         if [ "$Y" -lt "$YFrom" ] || [ "$Y" -gt "$YTo" ] ||
           { [ "$Y" -eq "$YFrom" ] && [ "$M" -lt "$MFrom" ]; } ||
           { [ "$Y" -eq "$YTo" ] && [ "$M" -gt "$MTo" ]; }; then
            flag=0
            continue
        fi

        echo "$line"


    done < temp.txt

    if [ $flag -eq 1 ]; then # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        echo "no records for patient $id from $DateFrom to $DateTo "
    fi

}

Abnormal_ID(){
    id=$1
    records=$(grep "^$id:" medicalRecord.txt)
    
    if [ -z "$records" ]; then # handling if no records found for patient
        echo "No records found for patient ID $id."
        return
    fi
    
    echo "Abnormal tests for patient ID $id:"
    while IFS= read -r record; do # loop over record of patient
        test_name=$(echo "$record" | cut -d',' -f1 | cut -d':' -f2 |  tr '[:upper:]' '[:lower:]' | xargs) # test name
        test_result=$(echo "$record" | cut -d',' -f3 | xargs) # test result
    
        range="${normal_ranges[$test_name]}" # ranges are taken from associative array
        # divide ranges into upper and lower
        lower_limit=$(echo $range | cut -d' ' -f1) 
        upper_limit=$(echo $range | cut -d' ' -f2)

          # compare test result with normal ranges of each test type, then print Abnormal
        if (( $(echo "$test_result < $lower_limit" | bc -l) )) || (( $(echo "$test_result > $upper_limit" | bc -l) )); then
            echo "$record"
        fi
    done <<< "$records"

}

search_Abnormal_by_testname(){

    while [ 0 -eq 0 ]
    do 
        printf "\nEnter Test Name: "
        read name
        check_name $name
        status=$?
            if [ $status -eq 0 ]
            then 
                break
            fi 
    done

    records=$(grep -i "$name" medicalRecord.txt)

    if [ -z "$records" ]; then # handling if no records found 
        echo "No records found for Test name $id."
        return
    fi

    echo  " Abnormal tests for $name are:"

    while IFS= read -r record; do # loop over record of patient
        test_name=$(echo "$record" | cut -d',' -f1 | cut -d':' -f2 | tr '[:upper:]' '[:lower:]' | xargs) # test name
        test_result=$(echo "$record" | cut -d',' -f3 | xargs) # test result
    
        range="${normal_ranges[$test_name]}" # ranges are taken from associative array
        # divide ranges into upper and lower
        lower_limit=$(echo $range | cut -d' ' -f1) 
        upper_limit=$(echo $range | cut -d' ' -f2)

          # compare test result with normal ranges of each test type, then print Abnormal
        if (( $(echo "$test_result < $lower_limit" | bc -l) )) || (( $(echo "$test_result > $upper_limit" | bc -l) )); then
            echo "$record"
        fi
    done <<< "$records"

}


check_Id(){
    id=$(echo "$1" | xargs)
    id=$(echo "$id" | tr -d "\n")
    digits=$(echo "$id" | wc -c)
  
    if [ $digits -ne 8 ] # don't forget null notation '\0'
    then
        printf "\n Invalid ID"
        return 1
    fi

    if [[ $id =~ ^[0-9]+$ ]]; then
        return 0
    else
        printf "\n Invalid ID"
        return 1
    fi
}

check_name(){
    name=$(echo "$1" | tr '[:upper:]' '[:lower:]') # from uppercase to lower case
    flag=0
    for key in "${!normal_ranges[@]}" ;do
        testname=$(echo "$key" | tr '[:upper:]' '[:lower:]')
        if [ "$name" = "$testname" ]
        then
            flag=1
        fi
    done
    if [ $flag -eq 0 ]
    then
    printf "\n Invalid Test name"
    return 1
    fi
    return 0
}

check_date(){
    date=$(echo "$1" | xargs)
    date=$(echo "$date" | tr -d "\n")
    year=$(echo "$date" | cut -d '-' -f1)
    month=$(echo "$date" | cut -d '-' -f2)

    if [ "$(echo "$date" | wc -c)" -ne 8 ]
    then
        printf "\nInvalid format ( YYYY-MM )" # YYYY-MM
        return 1
    fi
    
    if [ -z "$month" ] || [[ ! $month =~ ^[0-9]+$ ]] || [[ ! $year =~ ^[0-9]+$ ]]; then
        printf "\nInvalid format "
        return 1
    fi
    #!!!!!!!!! check year 4 chars , month 2 chars
    if [ "$(echo "$year" | wc -c)" -ne 5 ] || [ "$(echo "$month" | wc -c)" -ne 3 ]
    then
        printf "\nInvalid format"
        return 1
    fi
    if [ "$year" -ge 2025 ] || [ "$year" -le 0 ] || [ "$month" -gt 12 ] || [ "$month" -le 0 ]
    then
        printf "\nInvalid Date"
        return 1
    fi

    return 0

}

check_result(){
    result=$1

    if [[ "$result" =~ ^[0-9]+$ ]]; then # check for an integer that is positive
        return 0
    fi

    if [[ "$result" =~ ^[0-9]*\.[0-9]+$ ]] || [[ "$result" =~ ^[0-9]+\.[0-9]*$ ]]; then # check for a float with decimal point that is not negative
        return 0
    else
        printf "\n Invalid result "
        return 1
    fi

}

check_status(){
    status=$(echo "$1" | tr '[:upper:]' '[:lower:]' | xargs)
    if [ "$status" = "completed" ] || [ "$status" = "pending" ] || [ "$status" = "reviwed" ]
    then    
        return 0
    else 
        printf "\n Invalid status "
        return 1
    fi

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
        search_Abnormal_by_testname
        sleep 2
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



