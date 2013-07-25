UNIX TIPS
==========

"Unix is simple. It just takes a genius to understand its simplicity." 
    – Dennis Ritchie, Invetor of the C Programming Language


Unix Philosphy
=============
> This is the Unix philosophy: 
> Write programs that do one thing and do it well. 
> Write programs to work together. 
> Write programs to handle text streams, because that is a universal interface.
    – Douglas McIlroy


TEXT
=======
- Each program/process has 3 communication channels available to it:
  + Standard Input (STDIN)
  + Standard Output (STDOUT)
  + Standard Error (STDERR)
- Each comm. channel has an associated integer (called a "File descriptor"):
  + STDIN=0
  + STDOUT=1
  + STDERR=2
- In a terminal window:
  + STDIN reads from the keyboard
  + STDOUT & STDERR write to the term window

Redirect I/O for a great good
-----------------
- STDIN:
    + '<' allows you connect a program's STDIN to a file
    Examples:
        mail -s "Send mail from file" tyler@tylercipriani.com < /path/to/file.txt
        mysql -h sa2peop_sa2 < somedumpfile.sql

- STDOUT
    + '>' and '>>' redirect STDOUT
    + '>' replaces a target file's contents with a program's STDOUT
    + '>>' appends a program's STDOUT to a file
    + A file will be created if it does not exist
    Examples:
        echo "This is some text" > /tmp/somefile.txt
        ls -lh > this_directorys_contents.txt

- STDERR
    + '2>' redirects STDERR
      - USE CASE:
        sometimes the find command throws errors (if you don't have the 
        appropriate permissions to view a directory) to not see the errors
        in your terminal window but still see all the results (STDOUT) of 
        the find command , redirect STDERR to /dev/null (the system black hole). 
      - find . -type f -name "*.php" 2> /dev/null


File System Hierarchy
============
- EVERYTHING IS A FILE in Linux
- Your speakers are located at /dev/dsp
- The number of processor cores available to your system is located at /proc/cpuinfo

Run down of the FSH:
/          | Root of the filesystem
/bin       | system binaries—computer needs to boot
/boot      | boot loader (/boot/grub/grub.conf or menu.lst), Linux kernel (/boot/vmlinuz)
/dev       | System devices (more info: http://en.wikipedia.org/wiki/Device_file)
/etc       | System-wide configuration files
/home      | User configuration files, users can ususally only write files in their home directory
/lib       | shared library files used by system binaries
/media     | auto-mounting removable media (CDRom, USB Drives, etc)
/mnt       | temp filesystems (USB Drives mounted manually)
/opt       | "optional software", Libreoffice installs here, some sysadmins like to install software here
/proc      | provides kernel information as files
/root      | home directory for root user
/srv       | media served by the system - I think it makes sense to have website data here rather than /var/www
/sbin      | sysadmin binaries (e.g., /sbin/ifconfig gives you ip information)
/tmp       | temporary storage - cleaned frequently
/usr       | programs, libraries etc for all system users
/usr/bin   | programs installed for all users by linux (e.g. /usr/bin/find)
/usr/local | sysadmins (me) download and install things here (executables in /usr/local/bin, source files in /usr/local/src)
/usr/sbin  | more sysadmin binaries (e.g., /usr/sbin/usermod lets me modify a user)
/var       | data that chanes frequently is stored here (e.g. /var/log for log files /var/www/ for webservers)


FIND
========
- Find stuff in the Filesystem Heirarchy
- Usually located at /usr/bin/find
- Searches recursivly below specified search path
- more info and examples: man find

  find <search_path> [options]

Command Examples:
----------
Find a file name 'cats.txt' below current directory | find . -name 'cats.txt'
Find all files below current directory              | find . -type f
Find all directories below current directory        | find . -type d
.txt files                                          | find . -type f -name "*.txt"
case insensitive file name                          | find . -iname "nOtSuReOfCaSiNg.txt"
txt files recursively to a depth of 2               | find . -maxdepth 2 -type f -name "*.txt"
All NON text files                                  | find . -not -name "*.txt"
Files modified less than a day ago                  | find . -type f -mtime -1
Directories modified more than 10 days ago          | find . -type d -mtime +10
All Files greater than 100 MB                       | find . -type f -size +100M
All files smaller than 10 KB                        | find . -type f -size -10K
Remove all zip files bigger than 100MB              | find . -name "*.zip" -size +100M -exec rm -i "{}" \;
Remove all files in /tmp older than 2 days          | find /tmp -maxdepth 1 -type f -mtime +2 -exec rm -i "{}" \;


SED – find and replace
=======
- Used to find and replace in text stream
- Can be used to append to a file after or before a given pattern
- I mainly use it with Unix Pipes (e.g., with STDIN)

Command Examples (http://sed.sourceforge.net/sed1line.txt):
Change day into night in a file                        | cat <somefile.txt> | sed -e 's/day/night/g' > newfile.txt
ReName all text files to <whatever>-old.txt            | find . -maxdepth 1 -type f -iname '*.txt' | sed -e 's,\(\(.*\).txt\),mv "\1" "\2-old.txt",g' | /bin/bash
ReName all those text files back to <whatever>-old.txt | find . -maxdepth 1 -type f -iname '*.txt' | sed -e 's,\(.*\)-old.txt,mv "\0" "\1.txt",g' | /bin/bash
Add line to file after 3rd line                        | sed '3 a\
                                                       | some line' <somefile>.txt
Add line to file after regex pattern                   | sed '/pattern/a\
                                                       | some line' <somefile>.txt
Add a line at the end of the file                      | sed '$ a\
                                                       | some line at the end' <somefile>.txt
Print all lines between n1 and n2                      | sed -n 'n1,n2p'


CUT 
=====
- Print a column base on a delimeter
- The default delimeter is the tab character
- Works with Pipes to STDIN
- Useage:

  cut -d "<delimeter" -f "<field"

Command Examples:
---------
/etc/passwd is delimited by ":" so… first column | cat /etc/passwd | cut -d ":" -f $1
/etc/passwd 7th column                           | cat /etc/passwd | cut -d ":" -f $7


AWK - Like sed but different
=====
- I use a mix of cut, sed and grep instead of Awk
- Usage examples: http://www.thegeekstuff.com/2010/01/awk-introduction-tutorial-7-awk-print-examples/
- Oneliners: http://www.pement.org/awk/awk1line.txt

ENV
======
- Dictates your bash environment
- Usually located at /usr/bin/env

Command Examples:
----------
check shell environment                            | cat /etc/passwd | grep `whoami` | cut -d ':' -f 7
check what shell environments are installed        | cat /etc/shells
change your default shell                          | chsh `whoami` -s <valid login shell>
change another user’s shell                        | sudo chsh <username> -s <valid login shell>
switch users                                       | su <username> (or su - to switch to root)
list all variables on your environment             | env
set temp variable for shell session                | export VARNAME=value

where env vars are set                             | /home/<username>/.bashrc
"                                                  | /home/<username>/.bash_profile
"                                                  | grep -P '(^\s+\.|^\s+source)' .bashrc
"                                                  | grep -P '(^\s+\.|^\s+source)' .bash_profile

check specific variable                            | echo $<varname>
check system path                                  | echo $PATH
check if a program is installed and in system path | which <program_name>


CRON
======
- Cronjobs are sheduled system tasks
- Cronjobs are per user. 
  The root user has a different set of crons than the Tyler user
- Crontab is the program used to manage cronjobs
- To edit cronjobs use the command "crontab -e"

Cronjob Time Syntax:
------------
- m h dom m dow <what_to_do>
  - m - minute(0–59)
  - h - hour(0–23)
  - dom - day-of-month(0–31)
  - m - month(0-11)
  - dow - day-of-week(0–6)
  - <what_to_do> - anycommand

Crontab Examples:
-------
Execute <command> every 15 minutes                   | */15 * * * * <command>
Execute <command> at top of every hour on monday     | 0 * * * 1 <command>
Execute <command> at 10 after, 15 after and 20 after | 10,15,20 * * * * <command>


GREP – sorting output
=====
- Grep (g/re/p) stands for global regular-expression print. Its name is
  derived from a command in "ed" a Unix line-editor built in 1971.
- use flag i for case insensitve search
- use flag v to negate
- use flag P to use Perl-Compatible Regular Expressions (still "Highly Experimental" ::eye-roll::)
- use flag c to count matches (or pipe to wc -l [word-count lines - see man wc for details])

Grep Examples:
------
Find out if Apache is running                                         |
    - On CentOS                                                       | ps aux | grep -i httpd
    - On Debian                                                       | ps aux | grep -i apache
Find out how many instances of ffmpeg are running (wc -l counts lines)| ps aux | grep -i ffmpeg | grep -v grep | wc -l
Find text 'get_user' in all files below current dir with line numbers | grep -HiERn 'get_user' .
Same as above, don't include .svn directory                           | grep -HiERn 'get_user' . | grep -v '.svn'
How many proccessors does a system have                               | grep -c CPU /proc/cpuinfo
Same as above                                                         | cat /proc/cpuinfo | grep -i cpu    | wc -l
Same as above                                                         | grep -i cpu /proc/cpuinfo | wc -l
How many users are on a system besides you?                           | grep -cv `whoami` /etc/passwd
Same number as above + 1 (total system users)                         | cat /etc/passwd | wc -l
What shell is dave using?                                             | cat /etc/passwd | grep dave | cut -d: -f7


ACK – code search
======
- Ack searches files below the current directory
  recursively. It's ideal for use with code since
  it automatically excludes any .svn, .git or .cvs
  direcories from its search

- ack is not a gnu utility and therefore is not included by default on most
  unix-like systems. To install:
  on debian: apt-get install ack-grep
  on centos: yum install ack

- **AWK tutorial**—http://www.grymoire.com/Unix/Awk.html

Ack Examples:
-------
search for a pattern in all files recursively     | ack <pattern>
search for a pattern recursively case-insensitive | ack <pattern>
search php files for thing recursively            | ack --php <pattern>
search all files except javascript files          | ack --nojs <pattern>


Adding Users:
=========
- Difference between adduser & useradd                                          | [tl;dr no difference in Centos, use useradd in debian](http://www.garron.me/en/go2linux/useradd-vs-adduser-ubuntu-linux.html)
- Add a user                                                                    | `useradd <new_username>`
- Add an existing user to a group                                               | `usermod -a -G <new_username>`
- Find group ids for a user                                                     | `id -G <username>`
- Find groupnames for a user                                                    | `groups <username>`
- Edit defaults for adding a user (e.g., the user's shell, default group etc)   | `sudo vim /etc/default/useradd`
- Edit default files created for a user (e.g., .profile, .bashrc, .vimrc, etc ) | `sudo cp <file_to_add> /etc/skel/`
- Manage group permissions                                                      | `visudo` checkout lines that begin with `%<groupname>` or `<username>`


Additional Resources:
===============
http://www.thegeekstuff.com
http://www.linuxquestions.org
http://askubuntu.com

Fun Commands
==========
* **Generate a list of your most used commands**— 
```bash
history | sed "s/^[0-9 ]*//" | sed "s/ *| */\n/g" | awk '{print $1}' | sort | uniq -c | sort -rn | head -n 100 > commands.txt
```