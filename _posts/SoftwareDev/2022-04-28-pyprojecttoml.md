---
layout: post
title: "Modern Approach to Packaging and Structuring Python Projects"
author: "Emmet Friel"
categories: Programming
image: softwaredev/pyprojecttoml.jpeg
---


# Introduction 

Packaging, structuring and setting up python projects is something that I rarely took into consideration before this post partly because I don't often create projects in python, it's mainly scripting for automation but the scenario arose in work where we'll be creating an opensource CLI application and so the first thing that needed to be scoped out was finding best practice approach to setting up, structuring and packaging Python projects.<br>

Packaging and structuring Python projects involves three main components in the top level directory:
- **pyproject.toml**
- **setup.cfg**
- **setup.py**

<br>

# What will this blog show?

- Overview of pyproject.toml, setup.cfg and setup.py
- The layout and structure of a Python project
- Building and packaging an example app
- Testing the app works in a venv  
- Highlighting and applying best practice procedures

<br>

# Overview of pyproject.toml, setup.cfg and setup.py

Packaging and installing python projects has been around for 20 years using [distutils/setuptools](https://setuptools.pypa.io/en/latest/userguide/quickstart.html) and recently has been going through a transistional phase so you could achieve the same thing using a few different ways but the purpose of this post is to outline the up-to-date modern approach. Packaging and installing Python projects evolved from the initial setup.py to setup.cfg and now to the new and shiny pyproject.toml format.

- **Pyproject.toml**, first introduced in 2016 under PEP-518 as a configuration file for specifying build dependencies to be used alongside setuptools. The .toml format was adopted in PEP-621 (2020) for storing project metadata and finally adopted in the more recent PEP-660 for superseding setup.py for editable installs e.g ```pip install --editable . ``` for installing python projects in development mode.

At the time of writing since I noted Python is going through a transistional phase its recommended that you use all three configuration files in conjunction for a stable build while the pyproject.toml is still under active development as its still considered experimental. <br>

**The next sections shows how to utilize all three config files** <br><br>

# Setting up and structuring a Python project

Here is a standard layout of a Python repository:

```bash
emmet:helloworld-py/ $ tree                                                                                                  
.
├── CHANGES.txt
├── docs/
├── LICENSE.txt
├── pyproject.toml
├── README.md
├── setup.cfg
├── src/
│   └── hello_world
│       ├── __init__.py
│       └── module.py
└── tests/
```

- **CHANGES.txt**   : Changes made for each release
- **docs/**         : Documentation
- **LICENSE.txt**   : End User License Agreement (EULA) or license agreement
- **pyproject.toml**: In this case, storing build dependency configuration.
- **README.md**     : Project description
- **setup.cfg**     : Storing project metadata, importing packages and specifying entry points
- **src/**          : Source files directory
- **src/hello_world**: Package name containing Python module(s) e.g ```.py``` files
- **tests/**: Unit tests

**__init__.py**: Any directory with an ```__init__.py``` file is considered a Python package. The different modules in the package are imported in a similar manner as plain modules, but with a special behavior for the ```__init__.py``` file, which is used to gather all package-wide definitions. For more info, see the [python docs guide](https://docs.python-guide.org/writing/structure/) <br><br>


# Building and Packaging a Python App



<br><br>
# References

- https://pybit.es/articles/how-to-package-and-deploy-cli-apps/
- https://ianhopkinson.org.uk/2022/02/understanding-setup-py-setup-cfg-and-pyproject-toml-in-python/
- https://python-packaging-tutorial.readthedocs.io/en/latest/setup_py.html
- 