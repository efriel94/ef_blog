---
layout: post
title: "Using ansible-vault to pass sensitive information to playbooks"
author: "Emmet Friel"
categories: ansible
image: devops/ansible.jpeg
---

# Introduction 
In the first ansible post **Ansible: Getting Started** a problem occured where sensitive information was being passed to ansible in an unsecure fashion i.e. the information was in plaintext and could be seen by anyone or any adversary especially if the code was uploaded to public code repositories such as GitHub, Bitbucket etc. <br><br>

Ansible-vault provides a way to securely pass information in an encrypted format keeping the information private within your public repository to prying eyes.
<br><br>

# What this tutorial will show?
- Basics of ansible-vault
- Pass encrypted information to playbooks
<br><br>

# Create playbook
I will be using the same playbook from the last post where ansible updates the remote machine and installs an apache web server. The contents of the playbook can be seen below:
```bash
---
- name: Patch remote machine
  hosts: dev
  become: yes

  vars_files:
    - secrets.yml
  
  tasks:
    - name: Update repositories
      apt:
        update_cache: yes

    - name: Install apache2
      apt:
        name: apache2
        state: present
```

Note the new addition of  **vars_files** which specifies that we will be including a file with variables that we'd like to use in our playbook. This file (secrets.yml) will hold all our private information. The private information that it will hold is the sudo password<br><br>

# Basics of ansible-vault
Create secrets.yml file and input the sudo password for the remote machine:
```bash
ansible@server:~/Documents$ cat secrets.yml 
---
password: password123
```
Next step is to encrypt the file using ansible-vault. You will be prompted to enter a vault password, necessary for decrypting the information inside it:
```bash
ansible@server:~/Documents$ ansible-vault encrypt secrets.yml 
New Vault password: 
Confirm New Vault password: 
Encryption successful

ansible@server:~/Documents$ cat secrets.yml 
$ANSIBLE_VAULT;1.1;AES256
61346665386564303261336139646364373736323638366536353839326135616239346332336236
3064303834666632366134306135633839653734316536630a303735393535666639393666353931
37616364373464393364363839303661363932393334633039653764363036303733623961376138
3366383733363930310a643362376563383239366338323065623933363931383637393432633662
35663539326461336461643263623963626232353638323762373864353730626132
```
The contents of the file is now encrypted. Few ansible-vault commands to note:
- ```ansible-vault edit secrets.yml``` : This edits the information inside the vault
- ```ansible-vault view secrets.yml```: This outputs the content in plaintext
- ```ansible-vault decrypt secrets.yml```: This decrypts the content back to plaintext
<br><br>

# Edit inventory.ini to pass our encrypted sudo password
To pass variables, ansible uses moustaches (yes that's the actual name). Edit inventory.ini:
```bash
ansible@server:~/Documents$ cat inventory.ini 
[dev]
172.16.190.129 ansible_ssh_user=emmet ansible_sudo_pass={% raw %}"{{ password }}"{% endraw %}
```
We are passing ansible the password variable that was defined in secrets.yml.

<br>

# Run playbook
The password variable inside the vault is encrypted so when can tell ansible to prompt us for the vault password.
```bash
ansible@server:~/Documents$ ansible-playbook playbook.yml --ask-vault-pass
Vault password: 

PLAY [Patch remote machine] ***********************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [172.16.190.129]

TASK [Update repositories] ************************************************************************************
changed: [172.16.190.129]

TASK [Install apache2] ****************************************************************************************
ok: [172.16.190.129]

PLAY RECAP ****************************************************************************************************
172.16.190.129             : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
It works but its not fully automated because we don't want to input the password the playbook is executed. To bypass this, create a file called vault-password.txt, insert the vault password and pass ansible the file path.

```bash
ansible@server:~/Documents$ cat vault-password.txt 
mysupersecretvaultpassword
ansible@server:~/Documents$ ansible-playbook playbook.yml --vault-password-file vault-password.txt 

PLAY [Patch remote machine] ***********************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [172.16.190.129]

TASK [Update repositories] ************************************************************************************
changed: [172.16.190.129]

TASK [Install apache2] ****************************************************************************************
ok: [172.16.190.129]

PLAY RECAP ****************************************************************************************************
172.16.190.129             : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
Ansible unfortunately doesn't support passing the vault password in encrypted format so it's important keep that file safe with restricted permissions. And best not commit vault-password.txt to Git for everyone to see :) 