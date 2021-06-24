---
layout: post
title: "Ansible: Getting Started"
author: "Emmet Friel"
categories: ansible
image: devops/ansible.jpeg
---

# Introduction
Part of my work is translating academic research into tangible demonstrators and proof of concepts. I've been working on finding different ways to automate the creation, maintenance and access to these demonstrators. I've tested scripting via python however ansible came to be the best solution for provisioning infrastructure and virtual machines. This ansible series is notes that I've taken down from a number of weeks that were useful for getting to grips with the tool.<br><br>

# What is Ansible?
Ansible is an open source configuration management tool used for automating and orchestrating IT tasks across your infrastructure. Tasks such as rolling out updates at scale to machines to patch critical vulnerabilities, deploying new software and applications, provisioning cloud infrastructure and much more. Ansible by default connects to remote hosts over the SSH protocol to execute remote commands. <br><br>
An interesting and useless fact about Ansible is that the name is actually derived from the 1985 novel Ender's Game where it was a device used for instantenous communication across any distance.<br><br>


# What this tutorial will show?
This tutorial will show how to:
1. Install and setup ansible
2. Setup SSH key based authentication with your remote servers
3. Write and run a simple playbook to provision a remote server. 
<br><br>

The environment consists of two machines:
- ansible server: 172.16.190.131
- remote machine: 172.16.190.129
<br><br>

# 1. Install and setup ansible
Install prerequisites and check ansible version:

```bash
ansible@server:~$ sudo apt-get install ansible sshpass 
ansible@server:~$ ansible --version
ansible 2.9.6
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/ansible/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.8.5 (default, May 27 2021, 13:30:53) [GCC 9.3.0]
```
<br><br>

# 2. Set up SSH key-based authentication
This step is necessary for communicating with remote machines since ansible by default connects over SSH to run remote commands. To do this, I will go through the following steps:
- Install and run openssh-server on remote machine
- Generate public and private SSH keys
- Copy public SSH key from server to remote machine
- Start SSH agent and add SSH key to agent


First thing to do is to access your remote machine, install and run a SSH server.

```bash
emmet@ubuntu:~$ sudo apt-get install openssh-server
emmet@ubuntu:~$ systemctl status sshd.service 
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: e>
     Active: active (running) since Tue 2021-06-22 13:34:58 PDT; 1 day 14h ago
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 864 (sshd)
      Tasks: 1 (limit: 4617)
     Memory: 2.5M
     CGroup: /system.slice/ssh.service
             └─864 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
```
Now back on our server that's running ansible, generate SSH keys:

```bash
ansible@server:~/.ssh$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/ansible/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/ansible/.ssh/id_rsa
Your public key has been saved in /home/ansible/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:Ha1ICuXo377+8fJZfibOIXcuLLmyHl0XTim87wfJQIo ansible@server
The key\'s randomart image is:
+---[RSA 3072]----+
|      .          |
|     +     .o   .|
|    o . ...o.o + |
|   . . oEo.o. = .|
|    . . S o  +.o.|
|     . .   . .=. |
|      . . o oo+o.|
|       .  o+oB=++|
|       .+++==++*o|
+----[SHA256]-----+
```

Copy the public SSH key to the remote machine, you'll be prompted for the password for the remote user:
```bash
ansible@server:~/.ssh$ ssh-copy-id emmet@172.16.190.129
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
emmet@172.16.190.129\'s password: 

Number of key(s) added: 1

Now try logging into the machine, with:   \"ssh 'emmet@172.16.190.129'\"
and check to make sure that only the key(s) you wanted were added.
```
The public key is now added to the remote server. The final step is adding the private SSH key to ssh-agent. The ssh-agent is used for temporarily storing private keys and passphrases in memory so that you don't need to enter the passphrase every time for SSH authentication. Start the agent and add the private key:

```bash
ansible@server:~/.ssh$ eval $(ssh-agent)
Agent pid 2115
ansible@server:~/.ssh$ ssh-add
Identity added: /home/ansible/.ssh/id_rsa (ansible@server)
```
**Important note: This is only active in your current terminal so if you close the terminal or shutdown the machine its necessary to add your private key and passphrase to the agent again**

<br><br>

# Configure ansible environment
When creating your first ansible task there are two main files that describe how ansible behaves:
1. **inventory.ini** which is the hosts/inventory file. This is where you input what "hosts" or remote machines you would like ansible to run against. 
2. **ansible.cfg** defines ansibles global configuration behaviour. If you want local configuration to your task then just define the behaviour in the ansible playbook.

The default path ansible will look for these files are in /etc/ansible. 

Create two files:
- ansible.cfg
- inventory.ini


```bash
ansible@server:~/Documents$ cat ansible.cfg 
[defaults]
INVENTORY   = inventory.ini
```

Inside ansible.cfg, using [defaults] defines default behaviour. In my case I am pointing ansible to my own custom inventory file as I don't want ansible to use its default inventory file located at /etc/ansible. Contents of inventory.ini are below:

```bash
ansible@server:~/Documents$ cat inventory.ini
[dev]
172.16.190.129 ansible_ssh_user=emmet
```
I created a group called dev for my development machines with the remote IP address along with the user that I will log in as to execute ansible commands. The ansible variable **ansible_ssh_user** assigns the ssh user that ansible will use to log into the remote machines to execute ansible commands. Note that this is a local definition for that particular machine. If **ansible_ssh_user=emmet** was inserted into the global configuration file ansible.cfg (which is perfectly fine) then it would use that user for all machines in our inventory. <br>

Test that ansible can connect to remote machine by using ansible's ping module:
```bash
ansible@server:~/Documents$ ansible dev -m ping
172.16.190.129 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```
<br><br>

# Creating an ansible playbook
Playbooks provide a way to execute IT tasks at scale across the IT infrastructure i.e. updating debian packages, create new user or enforcing new security policies. <br><br>

Create a file playbook.yml that will install an apache2 server as well as updating the remote machine:

```bash
---
- name: Patch remote machine     # give the playbook a name
  hosts: dev                     # the group to specify for the playbook within our inventory file
  become: yes                    # become sudo user in remote machine, required for below tasks
  
  tasks:
    - name: Update repositories # this task is running sudo apt update
      apt:                      # Using ansibles apt module
        update_cache: yes       

    - name: Install apache2    
      apt:
        force_apt_get: yes      # forcing this task to use apt-get rather than ansibles apt module
        name: apache2           # specify name of package you would like to install
        state: present          # package is installed
```
Since we need to become sudo to perform this task its necessary to pass ansible the sudo password. Edit inventory.ini file:
```bash
ansible@server:~/Documents$ cat inventory.ini 
[dev]
172.16.190.129 ansible_ssh_user=emmet ansible_sudo_pass=admin234
```
**Note: For the purposes of this tutorial this method will suffice however it is not secure to pass sensitive information in plaintext and not recommended. Ansible-vault is typically used for passing sensitive information and will be covered in future posts.**

Run the playbook.

```bash
ansible@server:~/Documents$ ansible-playbook playbook.yml 

PLAY [Patch remote machine] ****************************************************

TASK [Gathering Facts] *********************************************************
ok: [172.16.190.129]

TASK [Update repositories] *****************************************************
changed: [172.16.190.129]

TASK [Install apache2] *********************************************************
ok: [172.16.190.129]

PLAY RECAP *********************************************************************
172.16.190.129             : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

Ansible updated the remote machine and installed an apache2 server.
