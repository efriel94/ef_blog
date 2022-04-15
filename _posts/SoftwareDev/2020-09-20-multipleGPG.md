---
layout: post
title: "Working with multiple GPG keys across multiple git identities"
author: "Emmet Friel"
categories: Programming
image: misc/github.jpeg
---

# Introduction

Its common to have multiple Git identities when working across different projects which can be difficult to manage but for the majority of us we usually have two git identities for signing commits: one for work use and one for personal use. This tutorial explains how to switch git identities automatically based on what directory your in.<br/>


# Prerequisites

 - Two GPG keys generated for two different emails. Refer to the [Git Documentation on GPG](https://docs.github.com/en/enterprise/2.13/user/articles/generating-a-new-gpg-key)<br/><br/>


# Configuring multiple git identities

The main Git configuration file is ```.gitconfig``` which can be found in the ```$HOME``` directory and is specfic to each user. Create two new git configuration files for work and personal use, see below.

```bash
-rw-r--r--  1 John John  234 May  8 15:52  .gitconfig
-rw-r--r--  1 John John   95 Sep 20 15:02  .gitconfig-local
-rw-r--r--  1 John John  137 Sep 20 15:02  .gitconfig-work
```

By default we are going to configure git to use our personal git identity for everything unless we are in a specific directory. Open up ```.gitconfig-local``` with a text editor and insert the contents based on your personal git identity:

```bash
emmet@homepc:~$ cat .gitconfig-local 
[user]
  name = John Doe
  email = johndoe@hotmail.co.uk
  signingkey = OEE3389VBDJH4531
```

**Note: You can find the key ID for your GPG secret key via ```gpg --list-secret-keys --keyid-format LONG``` which is then ```sec   rsa3072/OEE3389VBDJH4531```**

Save and Exit. Repeat the same for ```.gitconfig-work``` replacing name, email and signingkey ID with your git identity for work.

```bash
emmet@homepc:~$ cat .gitconfig-work 
[user]
  name = John Doe
  email = johndoe@company.net
  signingkey = BM2095449YAW90L1
```

Save and Exit. Create a new folder in Documents directory called ```work-projects``` which will be used for work related projects. Open the main git configuration file: ```.gitconfig``` and append the following to the file:

```bash 
# default case
[include]
        path = ~/.gitconfig-local

[includeIf "gitdir:~/Documents/work-projects/**/.git"]
        path = ~/.gitconfig-work
```

The includeIf condition allows us to automatically switch git identities when inside the work-projects directory to ```.gitconfig-work```.<br/><br/>

# Test automated switching

Git should now automatically detect the git identity based on the directory you are in. Run the following commands in your home directory:

```bash
emmet@homepc:~$ pwd
/home/john
emmet@homepc:~$ git config user.email 
johndoe@hotmail.co.uk
emmet@homepc:~$ git config user.signingKey 
OEE3389VBDJH4531
```

Git detects our configuration based on ```.gitconfig-local```. Navigate into ```Documents/work-projects```, clone any git project into work-projects directory, cd into it and then run the following commands again:

```bash
emmet@homepc:~/Documents/work-projects/tictactoe$ git config user.email 
johndoe@company.net
emmet@homepc:~/Documents/work-projects/tictactoe$ git config user.signingKey 
BM2095449YAW90L1
```

You can see Git automatically switching identities based on directories allowing us to manage multiple GPG keys when signing commits. 





