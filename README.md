# FileVault 📦🔒

FileVault is a secure file management CLI tool designed for programmers to store and manage their files efficiently. It allows users to upload files to designated servers based on file types, while keeping track of their uploaded files in a local SQLite database.

## Features 🌟
- **Secure File Uploads**: Upload files to specific servers based on their types (images, documents, code files).
- **Local Database Management**: Keep track of uploaded files in an SQLite database.
- **Ping Servers**: Check the availability of servers before uploading.
- **User Authentication**: Secure access to the file management system.

## Getting Started 🚀

### Prerequisites
- Bash shell
- SQLite3
- Curl
- Optional: `figlet` and `lolcat` for a colorful banner

### Installation 💻
1. Clone the repository:
   ```bash
   https://github.com/the-ai-developer/L2CFileVault.git
   cd L2C-sFileVault
Make the script executable:

```bash
chmod +x FileVault.sh
```
Run the script:

```bash
./FileVault.sh
```

## How It Works ⚙️

### Database Setup:

The script checks for the existence of a SQLite database at ~/file_registry.db. If it doesn't exist, it creates a new database with a files table.
### File Upload Process:

The script determines the type of file being uploaded based on its extension.
It pings the relevant server to check if it’s reachable before proceeding with the upload.
If the server is reachable, the file is uploaded, and details are logged into the SQLite database.
### Authorization:

Users are prompted to enter a password before they can perform any file management operations.
## Operations 📋
### 1. Upload Files
The script allows users to upload various file types, categorized into:
#### Images: jpg, jpeg, png, gif, bmp
#### Documents: pdf, docx, txt, odt
#### Code Files: zip, tar, gz, py, js, cpp, c, java, html, css, sh
### 2. Database Management
All uploaded files are logged in the SQLite database with the following fields:
#### id: Unique identifier for the file
#### name: Name of the file
#### size: Size of the file
#### server: Server where the file is uploaded
## Sample Usage 🖼️
Below are sample images demonstrating the CLI interface and file upload process.

## Sample CLI Interface
### Listing Files
![01](https://github.com/user-attachments/assets/2fe426ea-b47c-45ed-b696-9e21060ebe0b)

### Deleting Files
![02](https://github.com/user-attachments/assets/16caa4db-e408-4411-8e55-51110d8d3146)

### Uploading Files
![03](https://github.com/user-attachments/assets/cf7f1058-b286-47d4-abcb-dda7929c21bb)

### Downloading Files
![04](https://github.com/user-attachments/assets/74b12ca3-38ad-48f0-a1fd-0a885dbca5ae)


## Contributing 🤝
If you want to contribute to this project, please fork the repository and submit a pull request. For any suggestions or issues, feel free to open an issue in the repository.

## Acknowledgments 🙌
Inspired by various file management tools and motivated to create a secure and efficient solution for programmers.
