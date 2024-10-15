#!/bin/bash

database_file="$HOME/file_registry.db"

setup_database() {
    sqlite3 "$database_file" "CREATE TABLE IF NOT EXISTS files (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        size REAL NOT NULL,
        server TEXT NOT NULL
    );"
}

declare -A server_mapping
server_mapping=(
    ["images"]="SERVER-1"
    ["documents"]="SERVER-2"
    ["code_files"]="SERVER-3"
)

declare -A file_type_mapping
file_type_mapping=(
    ["images"]="jpg jpeg png gif bmp"
    ["documents"]="pdf docx txt odt"
    ["code_files"]="zip tar gz py js cpp c java html css sh"
)

blue_color="\033[1;34m"
yellow_color="\u001b[33m"
green_color="\033[92m"
red_color="\033[91m"
purple_color="\033[95m"
reset="\033[0m"
cyan="\033[96m"

show_banner() {
    if command -v figlet &>/dev/null && command -v lolcat &>/dev/null; then
         printf "\n"
         figlet -f ~/.local/share/fonts/3d.flf "L2C's Vault" | lolcat
         printf "\n"
    else
        echo -e "${green_color}"
        echo "------------------------------------------------"
        echo "|                File Vault CLI                |"
        echo "|     Secure File Management for Programmers   |"
        echo "------------------------------------------------"
        echo -e "${reset}"
    fi
}

get_server_for_file() {
    local file_extension=$1

    for file_type in "${!file_type_mapping[@]}"; do
        if [[ "${file_type_mapping[$file_type]}" =~ "$file_extension" ]]; then
            echo "${server_mapping[$file_type]}"
            return
        fi
    done

    echo "${server_mapping["images"]}"
}

ping_server() {
    local server=$1
    url="$server/ping"

    echo -e "${blue_color}[*] Pinging $server...${reset}"
    response=$(curl -s "$url")

    if [[ "$response" == "Server is running." ]]; then
        echo -e "${green_color}[+] $server is awake!${reset}"
        return 0
    else
        echo -e "${red_color}[-] $server is unreachable! Task cannot proceed.${reset}"
        return 1
    fi
}

authorize() {
    correct_password="L2C"  
    read -sp "Enter your password to proceed: " input_password
    echo
    if [[ "$input_password" == "$correct_password" ]]; then
        echo -e "${green_color}[+] Authorization successful!${reset}"
        return 0
    else
        echo -e "${red_color}[-] Incorrect password!${reset}"
        return 1
    fi
}

upload_file() {
    file_path=$1
    file_extension="${file_path##*.}"
    server=$(get_server_for_file "$file_extension")

    if ping_server "$server"; then
        url="$server/upload"
        if [[ -f "$file_path" ]]; then
            file_name=$(basename "$file_path")
            file_size=$(du -m "$file_path" | cut -f1)  # Size in MB

            echo -e "${blue_color}[*] Uploading file to $server...${reset}"
            response=$(curl -X POST -F "file=@$file_path" "$url")

            if [[ $? -eq 0 ]]; then
                echo -e "${purple_color}[>] Upload Successful!${reset}"
                sqlite3 $database_file "INSERT INTO files (name, size, server) VALUES ('$file_name', $file_size, '$server');"
                echo -e "${green_color}[+] File record added to database!${reset}"
            else
                echo -e "${red_color}[-] Upload failed!${reset}"
            fi
        else
            echo -e "${red_color}[-] File not found: $file_path${reset}"
        fi
    fi
}

list_files() {
    echo -e "${yellow_color}[•ᴗ•] Listing Files from Local Database:${reset}"
    result=$(sqlite3 $database_file "SELECT COUNT(*), SUM(size) FROM files;")
    file_count=$(echo $result | cut -d '|' -f1)
    total_size=$(echo $result | cut -d '|' -f2)

    if [[ "$file_count" -eq 0 ]]; then
        echo -e "${yellow_color}[ˣ‿ˣ] No Files Available!${reset}"
        return
    fi

    echo -e "${yellow_color}[•ᴗ•] Author: @PrinceTheProgrammer!${reset}"
    echo -e "${yellow_color}[•ᴗ•] Number of Files: $file_count${reset}"
    echo -e "${yellow_color}[•ᴗ•] Total Size: $total_size MB${reset}"
    echo -e "${yellow_color}[•ᴗ•] Files:${reset}"

    index=1

    sqlite3 $database_file "SELECT name, size, server FROM files;" | while IFS='|' read -r name size server; do
        echo -e "${cyan}${index}. ${reset}$name (${size} MB) - Stored on $server"
        index=$((index + 1))  # Increment the index
    done

}


delete_file() {
    file_name=$1
    row=$(sqlite3 $database_file "SELECT id, server FROM files WHERE name = '$file_name';")

    if [[ -z "$row" ]]; then
        echo -e "${red_color}[-] File not found in the database: $file_name${reset}"
        return
    fi

    file_id=$(echo "$row" | cut -d '|' -f1)
    server=$(echo "$row" | cut -d '|' -f2)

    if ping_server "$server"; then
        url="$server/delete/$file_name"
        echo -e "${blue_color}[*] Deleting file from $server...${reset}"
        response=$(curl -X DELETE "$url")

        if [[ $? -eq 0 ]]; then
            echo -e "${purple_color}[>] File Deleted Successfully!${reset}"
            sqlite3 $database_file "DELETE FROM files WHERE id = $file_id;"
            echo -e "${green_color}[+] File record removed from database!${reset}"
        else
            echo -e "${red_color}[-] File Deletion Failed!${reset}"
        fi
    fi
}

download_file() {
    file_name=$1
    row=$(sqlite3 $database_file "SELECT server FROM files WHERE name = '$file_name';")

    if [[ -z "$row" ]]; then
        echo -e "${red_color}[-] File not found in the database: $file_name${reset}"
        return
    fi

    server=$(echo "$row" | cut -d '|' -f1)

    if ping_server "$server"; then
        url="$server/download/$file_name"
        echo -e "${blue_color}[*] Downloading file from $server...${reset}"
        curl -O "$url"

        if [[ $? -eq 0 ]]; then
            echo -e "${purple_color}[>] Download Successful!${reset}"
        else
            echo -e "${red_color}[-] Download Failed!${reset}"
        fi
    fi
}

ping_servers() {
    for server in "${servers[@]}"; do
        ping_server "$server"
    done
}

while getopts ":u:c:f:" opt; do
    case $opt in
        u)  username=$OPTARG ;;
        c)  command=$OPTARG ;;
        f)  file_name=$OPTARG ;;  
        \?) echo "Invalid option -$OPTARG" >&2
            exit 1 ;;
    esac
done

if [[ -z "$username" ]]; then
    echo -e "${red_color}[-] Username is required!${reset}"
    exit 1
fi

# Ensure a command is provided
if [[ -z "$command" ]]; then
    echo -e "${red_color}[-] Command is required!${reset}"
    exit 1
fi

show_banner

if authorize; then
    case $command in
        upload)
            if [[ -n "$file_name" ]]; then
                upload_file "$file_name"
            else
                echo -e "${red_color}[-] File name is required for upload!${reset}"
                exit 1
            fi
            ;;
        list)
            list_files
            ;;
        download)
            if [[ -n "$file_name" ]]; then
                download_file "$file_name"
            else
                echo -e "${red_color}[-] File name is required for download!${reset}"
                exit 1
            fi
            ;;
        delete)
            if [[ -n "$file_name" ]]; then
                delete_file "$file_name"
            else
                echo -e "${red_color}[-] File name is required for deletion!${reset}"
                exit 1
            fi
            ;;
        ping)
            ping_servers
            ;;
        *)
            echo -e "${red_color}[-] Unknown command: $command${reset}"
            exit 1
            ;;
    esac
fi
