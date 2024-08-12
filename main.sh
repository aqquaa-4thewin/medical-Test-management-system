#!/bin/bash

#Shell scripting Project##
#Prepared by:
#Talin abuzulof 1211061
#Mayar Jafar 1210582
#Section " "

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
    echo -e "\n  == Welcome to the Medical Test Managment System == "
    echo "  Choose an operation by number:"
    echo " 1- Add a new medical test record"
    echo " 2- Search for a patient by ID"
    echo " 3- Search for abnormal tests for a test type"
    echo " 4- Find average test value for a test type"
    echo " 5- Update a test"
    echo " 6- Print All"
    echo " 7- Delete"
    echo " 8- Exit"
}

search_menu(){
    printf "\n 1-Retrieve all patient tests\n 2-Retrieve all up normal patient tests\n 3-Retrieve all patient tests in a given specific period\n 4-Retrieve all patient tests based on test status\n"
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

    
    printf "%s" "$(echo -e "\n$Id:$Name,$Date,$Result,$unit,$Status")" >> medicalRecord.txt # to remove new line with copy
    printf "\n  Record has been added successfully\n  "

}

Avg(){      # Calculating Average function #
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
            # Update Function #
update(){
    while [ 0 -eq 0 ]
    do 
        printf "\n Enter patient ID: "
        read id
        check_Id $id
        status=$?
        if [ $status -eq 0 ]
        then 
            break
        fi 
    done

    grep  "$id:" medicalRecord.txt > temp.txt

    if [ ! -s temp.txt ] ; then # check if file is empty
        echo -e "\n no records for patient $id "
        return
    fi

    printf "\n Available tests are:\n"
    cat -n temp.txt
    while [ 0 -eq 0 ]
    do 
        printf "\n Choose a test: "
        read choice
        if ! [[ $choice =~ ^[0-9]+$ ]]; then
            echo " Wrong input "
            continue
        fi 

        if [ $choice -le "$(cat temp.txt | wc -l)" ] &&  [ $choice -gt 0 ]
        then
        break
        fi
        printf "\n Invalid Option \n"
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
    printf "\n Result updated successfuly !\n"
}

search_id(){        # Search for patient ID #
    while [ 0 -eq 0 ]
    do 
        printf "\n Enter patient ID: "
        read id
        check_Id $id
        
        # id_found=$(grep -i "$id" medicalRecord.txt)
        # if [ -z "$id_found" ]; then # handling if no ID found 
        # echo "  ID $id is not found !!"
        # return
        # fi

        status=$?
        if [ $status -eq 0 ]
        then 
            break
        fi 

    

    done

    if ! grep -q "$id" medicalRecord.txt; then # check if patient id exist
        echo "No matches found for $id"
        return
    fi

    search_menu

    while [ 0 -eq 0 ]
    do 
        printf "\n Choose an option:  "
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
            echo " Invalid option !!";;
        esac
    done

}
print_by_ID(){     
    id=$1
    printf "\n Patient tests are:\n"
    grep  "$id:" medicalRecord.txt 
    

}


print_by_status(){
    id=$1
    grep  "$id:" medicalRecord.txt > temp.txt
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

    
    if ! grep -q "$status" temp.txt; then # check if status exists for that specific id
        echo -e "\n no records for patient $id with status $status"
        return
    fi
    grep "$status" temp.txt
    

}

print_in_period(){
    id=$1
    grep  "$id:" medicalRecord.txt > temp.txt
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
            check_date $DateTo
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
            continue
        fi
        flag=0
        echo "$line"


    done < temp.txt

    if [ $flag -eq 1 ]; then # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        echo "no records for patient $id from $DateFrom to $DateTo "
    fi

}

Abnormal_ID(){
    id=$1
    records=$(grep "$id:" medicalRecord.txt)
    
    if [ -z "$records" ]; then # handling if no records found for patient
        echo "No records found for patient ID $id."
        return
    fi
    
    flag=1
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
            flag=0
            echo "$record"
        fi
    done <<< "$records"

    if [ $flag -eq 1 ]; then # check if there are no Abnormal tests for patient id
        echo "No upnormal test for patient $id  "
    fi

}

search_Abnormal_by_testname(){  # Search Abnormal results by test name #

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

    flag=1
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
            flag=0
        fi
    done <<< "$records"
     if [ $flag -eq 1 ]; then # check that there are no Abnormal tests for a specific test name
        echo "No up-normal test for test name $name "
    fi

}


check_Id(){
    id=$(echo "$1" | xargs)
    id=$(echo "$id" | tr -d "\n")
    digits=$(echo "$id" | wc -c)

    if [ $digits -ne 8 ] # don't forget null notation '\0'
    then
        printf "\n  Invalid ID\n "
        return 1
    fi

    if [[ $id =~ ^[0-9]+$ ]]; then # check if id is all digits ( no characters )
        return 0
    else
        printf "\n  Invalid ID\n "
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
    printf "\n Invalid Test name ! \n"
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
        printf "\n  Invalid format ( YYYY-MM )\n" # YYYY-MM
        return 1
    fi
    
    if [ -z "$month" ] || [[ ! $month =~ ^[0-9]+$ ]] || [[ ! $year =~ ^[0-9]+$ ]]; then
        printf "\n  Invalid format\n "
        return 1
    fi
    #!!!!!!!!! check year 4 chars , month 2 chars
    if [ "$(echo "$year" | wc -c)" -ne 5 ] || [ "$(echo "$month" | wc -c)" -ne 3 ]
    then
        printf "\n  Invalid format\n "
        return 1
    fi
    if [ "$year" -ge 2025 ] || [ "$year" -le 0 ] || [ "$month" -gt 12 ] || [ "$month" -le 0 ]
    then
        printf "\n  Invalid Date\n"
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
        printf "\n  Invalid result \n"
        return 1
    fi

}

check_status(){
    status=$(echo "$1" | tr '[:upper:]' '[:lower:]' | xargs)
    if [ "$status" = "completed" ] || [ "$status" = "pending" ] || [ "$status" = "reviewed" ]
    then    
        return 0
    else 
        printf "\n  Invalid status \n "
        return 1
    fi

}


delete(){
    while [ 0 -eq 0 ]
    do 
        printf "\n Enter patient ID: "
        read id
        check_Id $id
        status=$?
        if [ $status -eq 0 ]
        then 
            break
        fi 
    done

    grep  "$id:" medicalRecord.txt > temp.txt

    if [ ! -s temp.txt ] ; then # check if file is empty 
        echo -e "\n no records for patient $id "
        return
    fi

    printf "\n Available tests are:\n"
    cat -n temp.txt
    while [ 0 -eq 0 ]
    do 
        printf "\n Choose a test to delete: "
        read choice
        if ! [[ $choice =~ ^[0-9]+$ ]]; then
            echo " Wrong input "
            continue
        fi 

        if [ $choice -le "$(cat temp.txt | wc -l)" ] &&  [ $choice -gt 0 ]
        then
        break
        fi
        printf "\n Invalid Option \n"
    done

    record=$(sed -n "${choice}p" temp.txt)
    

    grep -vF "$record" medicalRecord.txt > temp.txt # take everything except the record and put it in file
   
    printf "%s" "$(cat temp.txt)" > medicalRecord.txt # to remove new line with copy
    printf "\n Record deleted successfuly !\n"
}


##### Code starts 
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
            printf "\n Printing All Medical Records:\n"
            cat medicalRecord.txt
            echo ""
            sleep 2
        ;;

        "7") 
            delete
            sleep 2
        ;;

        "8")
            printf "\n System Closed ... GOODBYE :) \n"
            printf "\n"
            rm -r temp.txt
            exit
        ;;

        *)
        echo " Invalid option !!";;
    esac

done


