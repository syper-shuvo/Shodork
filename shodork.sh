#!/bin/bash
GREEN="\033[32m"
RESET_COLOR="\033[0m"

# Define the banner text
banner_text="
  ______  _                 _                _
 / _____)| |               | |              | |
( (____  | |__    ___    __| |  ___    ____ | |  _
 \____ \ |  _ \  / _ \  / _  | / _ \  / ___)| |_/ )
 _____) )| | | || |_| |( (_| || |_| || |    |  _ (
(______/ |_| |_| \___/  \____| \___/ |_|    |_| \_)
                                                   "

# Calculate terminal width and the banner width for centering
terminal_width=$(tput cols)
banner_width=51  # Width of the longest line in the banner

# Centering each line
while IFS= read -r line; do
    # Calculate the amount of padding needed for center alignment
    padding=$(( (terminal_width - banner_width) / 2 ))
    printf "%${padding}s"  # Add left padding
    echo -e "${GREEN}${line}${RESET_COLOR}"  # Print the line in green
done <<< "$banner_text"

echo " "
echo " "

read -p "                         Enter Search Query : " search
read -p "                         Output File Name : " output

# URL encoding function
url_encode() {
    local encoded=""
    local length="${#1}"

    for (( i=0; i<length; i++ )); do
        local char="${1:i:1}"
        case "$char" in
            [a-zA-Z0-9.~_-])
                encoded+="$char"
                ;;
            *)
                encoded+=$(printf '%%%02X' "'$char")
                ;;
        esac
    done
    echo "                     $encoded"  # Return the encoded string
}

encoded_string=$(url_encode "$search")

# Execute the curl command and handle errors
response=$(curl -s "https://api.shodan.io/shodan/host/search?key=s5By6j16t5yfQjFGLTm5vWOhbfrlbKdF&query=$encoded_string")

# Check if the response contains matches
if [[ $(echo "$response" | jq -r '.matches | length') -gt 0 ]]; then
    echo "$response" | jq -r '.matches[].ip_str' | tee "$output"
else
    echo "No matches found for the query."
    echo "$response" | jq -r '.error'  # Print any error message from the API response
fi

echo "                         Done..................."
