#!/bin/bash
echo "Testing bash scripting"


declare -A records

# Read the file line by line
while IFS= read -r line; do
    PatientID=$(echo "$line" | cut -d":" -f1 | xargs)
    TestName=$(echo "$line" | cut -d":" -f2 | cut -d"," -f1 | xargs)
    Testdate=$(echo "$line" | cut -d":" -f2 | cut -d"," -f2 | xargs)
    PatientResult=$(echo "$line" | cut -d":" -f2 | cut -d"," -f3 | xargs)
    Testunit=$(echo "$line" | cut -d":" -f2 | cut -d"," -f4 | xargs)
    Teststatus=$(echo "$line" | cut -d":" -f2 | cut -d"," -f5 | xargs)

    # Declare an associative array for the person
    declare -A person=(
        ["name"]="$TestName"
        ["date"]="$Testdate"
        ["result"]="$PatientResult"
        ["unit"]="$Testunit"
        ["status"]="$Teststatus"
    )

    # Serialize the associative array and store it in the main records array
    records["$PatientID"]="$(declare -p person)"
done < newfile.txt

# Function to display the contents of the associative arrays
display_records() {
    for id in "${!records[@]}"; do
        
        echo "ID: $id"
        echo "Name: ${person[name]}"
        echo "Date: ${person[date]}"
        echo "Result: ${person[result]}"
        echo "Unit: ${person[unit]}"
        echo "Status: ${person[status]}"
        echo ""
    done
}


readMedicalTests(){

    while IFS= read -r line; do
    symbol=$(echo "$line" | cut -d";" -f1 | cut -d"(" -f2 | cut -d")" -f1 | xargs)
    TestName=$(echo "$line" | cut -d";" -f1 | cut -d"(" -f1 | xargs)
    upperRange=$(echo "$line" | sed -n 's/.*< \([0-9.]*\).*/\1/p')
    lowerRange=$(echo "$line" | sed -n 's/.*> \([0-9.]*\),.*/\1/p')
    Testunit=$(echo "$line" | cut -d":" -f2 | cut -d"," -f4 | xargs)

    # Declare an associative array for the person
    declare -A testInfo=(
        ["name"]="$TestName"
        ["upper"]="$upperRange"
        ["lower"]="$lowerRange"
        ["unit"]="$Testunit"
    )

    # Serialize the associative array and store it in the main records array
    tests["$symbol"]="$(declare -p testInfo)"
done < medicalTest.txt

}


# Call the function to display the records
display_records

