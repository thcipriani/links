#Linux Tips
##Fun Commands
* **Generate a list of your most used commands**— 
```bash
history | sed "s/^[0-9 ]*//" | sed "s/ *| */\n/g" | awk '{print $1}' | sort | uniq -c | sort -rn | head -n 100 > commands.txt
```

##AWK
* **AWK tutorial**—http://www.grymoire.com/Unix/Awk.html