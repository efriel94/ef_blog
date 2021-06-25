---
layout: post
title: "Libsecret: Securely passing Git credentials"
author: "Emmet Friel"
categories: Git
image: git/keyring.png
---

# Introduction
I was working on a project recently that I was prevented from using SSH authentication for pushing code so it quickly became a burden inputting username and access token into the prompt. Git has three options for storing credentials:
1. Cache credential helper (stores passwords in memory)
2. Store credential helper (stores passwords in plaintext)
3. Use a third party solution

I could cache the Git credentials in memory which is secure but not persistent. I opted for a third party solution and stumbled across <a href="https://wiki.gnome.org/Projects/Libsecret" target="_blank_">GNOME's libsecret package</a>:

> Libsecret is a library for storing and retrieving passwords and other secrets. It communicates with the "Secret Service" using D-Bus. gnome-keyring and ksecretservice are both implementations of a Secret Service.

<br>

# Installation

```bash
sudo apt-get install libsecret-1-0 libsecret-1-dev git build-essential 
cd /usr/share/doc/git/contrib/credential/libsecret 
sudo make 
git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret
```
Passwords are stored in: ```/.local/share/keyrings``` directory. 

<br>

# Store Git password to libsecret

The next time you Git push, input your credentials, libsecret will store credentials within the encrypted keyring and Git will use libsecret for decrypting credentials for all proceeding authentications. That's it.