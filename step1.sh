#!/bin/bash
tr -s \ <"$1" >tmp.txt && mv tmp.txt "$1"
sed -e 's/$/\\\\/' -i "$1"
while IFS='' read -r line || [[ -n "$line" ]]; do
    echo ${line// /&}''
done < "$1" >tmp.txt && mv tmp.txt "$1"
