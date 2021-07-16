---
layout: post
title: "Secure variable secrets in playbooks using Ansible Vault"
author: "Emmet Friel"
categories: ansible
image: devops/ansible.jpeg
---

# Introduction 
In the first ansible post **Ansible: Getting Started** a problem occured where sensitive information was being passed to the playbooks in an unsecure fashion i.e. the information was in plaintext and could be seen by anyone or any adversary especially if the code was uploaded to public or private code repositories such as GitLab, GitHub, Bitbucket etc. <br><br>

Ansible-vault provides a way to securely pass information in an encrypted format to your playbooks keeping the information private within your public repository to prying eyes.
<br><br>

# What this tutorial will show?
- Basics of ansible-vault
- Pass encrypted information to playbooks

<br>

# Environment overview
```bash
$ ls
ansible.cfg inventory.ini main.yml secrets.yml
```
<br>

# Create playbook
I will create a playbook for cloning a Git repo from a private repository on a company domain that requires a username and password. The contents of the playbook will checkout a branch and clone from a remote repository onto a remote VM. The contents of main.yml can be seen below:
```bash
---
- name: Ansible secrets demo
  hosts: dev
  become: yes

  vars_files:
    - secrets.yml
  
  tasks:
    - name: Clone repository
      git:
        repo: {% raw %}"https://{{ username }}:{{ password }}@{{ repo_url }}"{% endraw %}
        dest: {% raw %}"/home/{{ user }}/{{ demo_name }}"{% endraw %}
        version: develop
```

I am using ansible's Git module which the full reference can be seen from ansible's Git reference page on their website. Note the new addition of  **vars_files** which specifies that we will be including a file with variables that we'd like to use in our playbook. This file (secrets.yml) will hold all our private information. The private information that we would like to keep secret in our playbook is anything inside the curly braces {% raw %}{{ }}{% endraw %} or moustaches as hipster developers would call them. I'm not going to call them that.<br><br>


# Basics of ansible-vault
Create secrets.yml file which holds our private information:
```bash
$ cat secrets.yml
---
username: johndoe@whatever.co.uk 
password: mysupersecretgitpassword
repo_url: company.gitlab.co.uk/johndoe/my_app/project.git
user: john
demo_name: my_app 
```
Next step is to encrypt the file using ansible-vault. You will be prompted to enter a vault password, necessary for decrypting the information inside it:
```bash
$ ansible-vault encrypt secrets.yml 
New Vault password: 
Confirm New Vault password: 
Encryption successful

$ cat secrets.yml 
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
To pass variables, ansible uses the curly braces. Edit inventory.ini:
```bash
$ cat inventory.ini 
[dev]
172.16.190.129 ansible_ssh_user=emmet ansible_sudo_pass={% raw %}"{{ sudo_pass }}"{% endraw %}
```
We are passing ansible the password variable that was defined in secrets.yml.

<br>

# Run playbook
The password variables inside the vault is encrypted so its necessary to pass ansible the vault password to use those variables in secrets.yml. You can pass ansible the vault password using two methods:
- Manually input the password in the terminal prompt
- Pass ansible the path to a file (unecrypted) that contains the vault password
<br>

To manually input the vault password into the terminal prompt, use ```--ask-vault-pass```
```bash
$ ansible-playbook playbook.yml --ask-vault-pass
Vault password: 

PLAY [Ansible secrets demo] ***********************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [172.16.190.129]

TASK [Clone repository] ****************************************************************************************
changed: [172.16.190.129]

PLAY RECAP ****************************************************************************************************
172.16.190.129             : ok=1    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
It works but its not fully automated. To remove the burden of inputting passwords everytime a playbook is executed, create a normal text file called vault-password.txt, insert the vault password and pass ansible the file path using ```--vault-password-file``` argument. Its important to store vault passwords in a secure location.

```bash
$ cat vault-password.txt 
v@uLtp@44W0rd_!
ansible-playbook playbook.yml --vault-password-file vault-password.txt 

PLAY [Ansible secrets demo] ***********************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [172.16.190.129]

TASK [Clone repository] ****************************************************************************************
changed: [172.16.190.129]

PLAY RECAP ****************************************************************************************************
172.16.190.129             : ok=1    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
Ansible unfortunately doesn't support passing the vault password in encrypted format so it's important keep that file safe with restricted permissions. And best not commit vault-password.txt to Git for everyone to see :) 