---
layout: post
title: "Structuring, Packaging and Installing Python Projects"
author: "Emmet Friel"
categories: Programming
image: softwaredev/pyprojecttoml.jpeg
---


# Introduction 

Packaging, structuring and setting up Python projects is something that I rarely took into consideration before this post partly because I don't often create projects in python, it's mainly scripting for automation but the scenario arose in work where we'll be creating an opensource CLI application and so the first thing that needed to be scoped out was finding best practice approach to setting up, structuring and packaging Python projects.<br>

Packaging and structuring Python projects involves three main components in the top level directory:
- **pyproject.toml**
- **setup.cfg**
- **setup.py**

<br>

# What will this blog show?

- Overview of pyproject.toml, setup.cfg and setup.py
- The layout and structure of a Python project
- Building and packaging an example app
- Install the app in a python venv
- Testing the app

<br>

# Overview of pyproject.toml, setup.cfg and setup.py

Packaging and installing python projects has been around for 20 years using [distutils/setuptools](https://setuptools.pypa.io/en/latest/userguide/quickstart.html) and recently has been going through a transistional phase so you could achieve the same thing using a few different ways but the purpose of this post is to outline the up-to-date modern approach, time of publishing this. Packaging and installing Python projects evolved from the initial setup.py to setup.cfg and now to the new and shiny pyproject.toml format.

- **pyproject.toml**, first introduced in 2016 under PEP-518 as a configuration file for specifying build dependencies to be used alongside setuptools. The .toml format was adopted in PEP-621 (2020) for storing project metadata and finally adopted in the more recent PEP-660 for superseding setup.py for editable installs e.g ```pip install --editable . ```. This installs python projects in development mode.

At the time of writing since I noted Python is going through a transistional phase **its recommended that you use all three configuration files in conjunction** for a stable build while the pyproject.toml is still under active development as its still considered experimental.<br>

**The next sections shows how to utilize all three config files** <br><br>

# The layout and structure of a Python project

Here is a common structure of a Python repository using the src/ layout:

```bash
emmet:python-project/ $ tree                                         
.
├── CHANGES.txt
├── docs
├── LICENSE
├── pyproject.toml
├── README.md
├── setup.cfg
├── setup.py
├── src
│   └── hello_world
│       ├── __init__.py
│       └── main.py
└── tests

```

- **CHANGES.txt**   : Changes made for each release
- **docs/**         : Documentation directory
- **LICENSE.txt**   : End User License Agreement (EULA) or license agreement
- **pyproject.toml**: In this case, storing build dependency configuration.
- **README.md**     : Project description
- **setup.cfg**     : Storing project metadata, importing packages and specifying entry points
- **setup.py**      : Simple boilerplate 
- **src/**          : Source files directory
- **src/hello_world**: Package name containing Python module(s) e.g ```.py``` files
- **tests/**: Unit tests

**__init__.py**: Any directory with an ```__init__.py``` file is considered a Python package. The different modules in the package are imported in a similar manner as plain modules, but with a special behavior for the ```__init__.py``` file, which is used to gather all package-wide definitions. For more info, see the [python docs guide](https://docs.python-guide.org/writing/structure/) <br>


### setup.cfg

```python
[metadata]
name = helloworld
version = 0.0.1
author = Emmet Friel
author_email = e.friel@myemail.co.uk
description  = A sample hello world application project
long_description = file: README.md
long_description_content_type = text/markdown
url = https://mygithubrepo.co.uk/helloworld-sample.git
classifiers =
    Programming Language :: Python :: 3
    License :: OSI Approved :: MIT License
    Operating System :: OS Independent

[options]
package_dir = 
    = src
packages = find:
python_requires = >=3.6
install_requires =
    numpy >= 1.22.3

[options.packages.find]
where = src

[options.entry_points]
console_scripts = 
    myapp1 = hello_world.mymodule:function1
    myapp2 = hello_world.mymodule:function2
```

**[metadata]**: Defining project metadata and information <br>
**[options]** : Defines project requirements and automatically searches for python packages in the `src/` subdirectory using `package_dir`. Also note that `[options.packages.find] where` corresponds to the same value in `package_dir` <br>
**[options.entry_points]**: Entry points are a useful feature of the Python ecosystem. Every project installed from a distribution it can advertise components to be used by other code. Installed distributions can specify `console_scripts` entry points, each one simple referring to a different Python function. When pip installs the distribution, it will create a binary for each entry point. <br>

I am creating two entry points for this application so once I install the Python project it will produce two Python binarys, each one with a different functionality.<br><br>

### pyproject.toml

```python
[build-system]
requires=["setuptools>=62", "wheel"]
build-backend="setuptools.build_meta"
```

The `build-system` table is used to tell the build frontend i.e **build** or **pip** what build system to use i.e. **setuptools,poetry** etc and other plugins required such as **wheel** to build the package. We could have certainly included our project metadata, dependencies etc into the `pyproject.toml` however for the purpose of this tutorial I opted to define it in `setup.cfg`. <br> 

Have a look at official Python documentation on how to do this: [PEP-621](https://peps.python.org/pep-0621/) <br><br>

### setup.py 

```python
from setuptools import setup

setup()
```

Simple boilerplate is required to work with setuptools for editable installs i.e. ```pip install --editable```. This is usually for working on the project in development mode as we don't wish to perpetually reinstall the project once we edit a line of code. 

### src/hello_world/mymodule.py

```python
def function1():
    print("This my application being executed from function 1")

def function2():
    print("This is my application being executed from function 2")

if __name__ == "main":
    """
    Default entry point if executing the script natively i.e python3 mymodule.py
    """
    function1()
```


<br><br>



# Building and Packaging the Python Project

At the root of the directory, using the Python build module:

```bash
emmet:python-project/ $ python3 -m build .
```

After Python successfully builds the project, it will create a new `dist/` directory and inside it will contain two artifacts:

```bash
emmet:python-project/ $ ls dist
helloworld-0.0.1-py3-none-any.whl  helloworld-0.0.1.tar.gz
```
The project is now packaged into two formats where Python provides two options of installing the packaged distributions but its recommended to use `.whl` wheel format. The wheel format is a ZIP archive which provides an easy Python specfic way to ship and distribute libraries and ensures software is installed predictably and quickly rather than building from source each time. <br><br>

# Installing the Wheel distribution in a Virtual Environment

Create and activate a Python venv:

```bash
emmet:python-project/ $ python3 -m venv .myvenv
emmet:python-project/ $ source .myvenv/bin/activate
```
Install our newly built wheel into the virtual env (.myenv):
```bash
(.myvenv) emmet:python-project/ $ pip install dist/helloworld-0.0.1-py3-none-any.whl
Processing ./dist/helloworld-0.0.1-py3-none-any.whl
Collecting numpy>=1.22.3
Using cached numpy-1.23.0-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (17.1 MB)
Installing collected packages: numpy, helloworld
Successfully installed helloworld-0.0.1 numpy-1.23.0
```
<br>

# Testing the installed app

Since the build configuration specified two entry points i.e **myapp1,myapp2**, configured in `setup.cfg` each one pointing to a different function, the installed distribution will produce two binary command-line wrappers:

```zsh
(.myvenv) emmet:python-project/ $ cd .myvenv/bin
(.myvenv) emmet:bin/ $ ls
activate  activate.csh  activate.fish  Activate.ps1  easy_install  easy_install-3.8  f2py  f2py3  f2py3.8  myapp1  myapp2  pip  pip3  pip3.8  python  python3
```

Testing:

```zsh
(.myvenv) emmet:bin/ $ ./myapp1
This my application being executed from function 1
(.myvenv) emmet:bin/ $ ./myapp2
This is my application being executed from function 2
```


<br><br>
# References

- https://pybit.es/articles/how-to-package-and-deploy-cli-apps/
- https://ianhopkinson.org.uk/2022/02/understanding-setup-py-setup-cfg-and-pyproject-toml-in-python/
- https://python-packaging-tutorial.readthedocs.io/en/latest/setup_py.html
- 