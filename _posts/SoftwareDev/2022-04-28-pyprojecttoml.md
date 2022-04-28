---
layout: post
title: "Walkthrough on pyproject.toml and setup.cfg"
author: "Emmet Friel"
categories: Programming
image: softwaredev/pyprojecttoml.jpeg
---

# Introduction 

Planning structure in python projects is something that I never took into consideration partly because I don't often create projects in python, its mainly scripts for automation but I am an advocate of best practice procedure so the scenario arose in work where we'll be creating an opensource CLI application and the first thing that needed to be decided was how to structure and package the project.<br>

Out with the ancient method of setup.py and in with the shiny pyproject.toml method.

# What will this blog show?

- Building and packaging an example app locally using pyproject.toml and setup.cfg
- Testing the app works in a venv  
- Highlighting and applying best practice procedures.

