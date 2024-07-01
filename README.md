# Automating user and group creation: HNG11 Task 1

This script automates the creation of user accounts and their associated groups on a Linux system. It reads user data from an input file and logs all activities.

## Features
- **Automated User Creation**: Automate user account creation with home directories, saving you time and effort..
- **Group Management**: Easily assign users to primary and additional groups based on your data file.
- **Password Generation**:  Generate strong, random passwords for each user and store them securely with restricted access.
- **Detailed Logging**:Track all script actions and potential errors for comprehensive auditing in the /var/log/user_management.log file`.

## Requirements

- Linux environment (tested on Ubuntu 20.04 LTS)
- The script must be run as the root user.
- The input file must be in the format: `username;group1,group2,...`
- `openssl` must be installed to generate random passwords.

## Usage
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/HNG_SATGE1--Scripting
   cd HNG_SATGE1--Scripting
   ```

2. **Save the script to a file, e.g., `create_users.sh`, and make it executable:**
    ```bash
    chmod +x create_users.sh
    ```

3. **Prepare your input file, e.g., `User_Data.txt`, in the following format:**
    ```
    username1;group1,group2
    username2;group3,group4
    ```

4. **Run the script with the input file as an argument:**
```bash
sudo ./create_users.sh User_Data.txt
  ```

5. **Logs**
User creation activities are logged in /var/log/user_management.log.
Generated passwords are stored securely in /var/secure/user_passwords.txt.
```bash
cat /var/log/user_management.log
cat var/secure/user_passwords.txt
  ```
## Notes 
The script will skip users that already exist and log the activity.
Ensure the input file is correctly formatted to avoid errors during user creation



## Contributions

Contributions are welcome! Feel free to submit issues or pull requests.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
