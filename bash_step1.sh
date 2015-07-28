#!/bin/bash
for file in "$@"
do
    tr -s \ <"$file"> tmp.txt && mv tmp.txt "$file"
    COUNT=0
    while IFS='' read -r line || [[ -n "$line" ]]; do
        COUNT=$(( $COUNT + 1 ))        
        sed -i ''$COUNT'i\'${line// /&}'' "$file"
        sed -i ''$(( $COUNT + 1 ))'d' "$file"
        [[ $line == all:* ]] && line+=" \\"
    done < "$file"
    sed -e 's/$/\\\\/' -i "$file" 
done
