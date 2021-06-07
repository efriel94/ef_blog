---
layout: post
title: "Python Virtual Environment in VSCode"
author: "Emmet Friel"
categories: SoftwareDev
image: softwaredev/python-venv.jpeg
---

# Why use a virtual environment?
Its good practice to isolate dependencies and libraries between applications whatever language your coding in so everything isn't lumped into your system wide dependency list. It makes installing, maintaining and version controlling project dependencies alot easier and porting the project over to other people to use means that their not installing unncessary dependencies. Visual Studio Code IDE provides a nice feature for creating and working with Python environments. By default, the Python vscode extension looks for and uses the first Python interpreter it finds in the system path. If it doesn't find an interpreter, it issues a warning. We can change this default behaviour to point VSCode to a Python interpreter that will activate a virtual environment.

<br>

# Dependencies

```bash
sudo apt-get install python3-pip python3-venv
pip3 install virtualenv
```
<br>

# Create project structure 

```bash
mkdir project
```

Inside projects folder create two additional directories:
- **src/**,  where it will store your python source code.
- **virtual_env/**, where it will hold all the virtual environment configuration files

```bash
cd project
mkdir src/
python -m venv virtual_env/
```
Navigate into src/ directory, create an empty python file and open up vscode:

```bash
cd src/
touch test.py
code .
```
<br>

# Add python virtual environment to vscode

- Install two vscode extensions: ```Python, Python for VSCode```
- Open up workspace settings (settings.json) via:

```bash
CTRL + shift + p
Preferences: Open Workspace Settings (JSON)
```
Insert the full path to your python virtual environment folder in settings.json:

```bash
{ 
    "python.pythonPath": "/home/user/Documents/project/virtual_env" 
}
```
Save and exit settings.json. <br>
If you have terminals open on vscode then close them all and open a new terminal. You should see vscode automatically recognising your python virtual environment in the terminal as seen below:

![image]({{site.github.url}}/assets/img/softwaredev/python-venv.png)
<br>

From here you can install and maintain your python packages which are stored on your virtual environment:

```bash
virtual_env/lib/python3.8/site-packages
```
<br>

## Important notes

If it doesn't work first time around these work arounds I found that conflicted with the python virtual environment that needed removed:

- Disable and uninstall the Code Runner extension as it will conflict with your python interpreter
- If your like me who version controls your python in your .bashrc file using aliases then remove the alias completely and re source your bashrc file: ```source ~/.bashrc```