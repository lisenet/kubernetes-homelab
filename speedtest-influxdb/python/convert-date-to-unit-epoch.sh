#!/bin/bash
set -e

# Convert date time string to epoch to use with InfluxDB.

input_file="./data/speedtest-line-protocol.txt"
output_file="./data/speedtest-with-epoch-time.txt"

while IFS= read -r line; do
  echo -n "$(printf '%s\n' "${line}"|cut -d" " -f1-2)" >> "${output_file}"
  echo -n " " >> "${output_file}"
  date -d "$(printf '%s\n' "${line}"|cut -d" " -f3)" +"%s" >> "${output_file}"
done < "${input_file}"

exit 0
