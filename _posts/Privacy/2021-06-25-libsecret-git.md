---
layout: post
title: "Libsecret: Securely pass Git credentials"
author: "Emmet Friel"
categories: Programming
image: git/keyring.png
---

# Introduction
The scenario occured where I was working on a project recently and I was unable to use SSH for pushing code upstream to a private repository so it quickly became a burden inputting username and access token into the prompt over and over. I needed a way to cache or store my Git credentials in a secure fashion without the need to input username/password every push. Step up GNOME's libsecret package. <br><br>
Basically, Git has three options for storing credentials:
1. Cache credential helper (stores passwords in memory)
2. Store credential helper (stores passwords in plaintext)
3. Use a third party solution

I could cache the Git credentials in memory which is secure but not persistent. I opted for a third party solution and stumbled across <a href="https://wiki.gnome.org/Projects/Libsecret" target="_blank_">GNOME's libsecret package</a>:

> Libsecret is a library for storing and retrieving passwords and other secrets. It communicates with the "Secret Service" using D-Bus, gnome-keyring and ksecretservice are both implementations of a Secret Service.

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

The next time you Git push, input your credentials, libsecret will store credentials within the encrypted keyring and Git will use libsecret for decrypting credentials for all proceeding authentications. That's it. <br>

If you wish to remove the credentials remove the files within keyring directory. <br><br>

# Conclusion

The only issue is the Identity and Access Management (IAM) of your GNOME keyring's which you need to take care of the permissions and access to. The GNOME libsecret uses sudo permissions by default.   