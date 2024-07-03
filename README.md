# AUTH_LOG_MONITOR

## Objective

The objective of the **auth_log_monitor** script is to have a program that runs in the background and records all the failed login attempts that show up in the /var/log/auth.log file.
The information recorded by the script is sorted into files that are named using the IP address from which the failed login attempts were occuring, each file contains all the failed attempts from the specific IP address.


### Skills Learned

- Better understanding of how to write shell scripts, the usage of for loops and if conditions.
- Learning about the broad capabilites of the sed command.
- Learning about AWK, grep, cut, sort, and uniq for filtering.


### Tools Used

- File Operations:
    * mv
    * ls -1
    * -d
- Text Processing:
   * grep
   * sed
   * awk
   * cut
   * sort
- System Monitoring & Management:
   * pgrep
   * kill
- Log Management:
   * tail
   * nl
- Control Flow:
   * for
   * while
   * if

## How to use

Make sure you are operating as root or as a user that belongs to the sudo group.
Start the script by typing: bash auth_log_monitor.sh or ./auth_log_monitor.sh
Selected 1 to start the script, or select 2 to stop it.
The script with generate a folder in your current directory where all the data will be stored.
