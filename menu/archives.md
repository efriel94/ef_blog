---
layout: page
title: "Archives"
---

<br>
# Year
--------
<ul>
{% for post in site.posts %}
  {% assign currentdate = post.date | date: "%Y" %}
  {% if currentdate != date %}
    <h3>{{ currentdate }}</h3>
    {% assign date = currentdate %} 
  {% endif %}
    <li><a href="{{ post.url }}">{{ post.title }}</a></li>
{% endfor %}
</ul>

<br>
# Category
--------
{% comment %}
#
#  Change date order by adding '| reversed'
#  To sort by title or other variables use {% assign sorted_posts = category[1] | sort: 'title' %}
#
{% endcomment %}
{% assign sorted_cats = site.categories | sort %}
{% for category in sorted_cats %}
{% assign sorted_posts = category[1] | reverse %}
<h3 id="{{category[0] | uri_escape | downcase }}">{{category[0] | capitalize}}</h3>
<ul>
  {% for post in sorted_posts %}
 	<li><a href="{{ site.url }}{{ site.baseurl }}{{  post.url }}">{{  post.title }}</a></li>
  {% endfor %}
</ul>
{% endfor %}
<br>

# Cheatsheets
-------
- <a href="https://www.blackmoreops.com/2016/12/20/kali-linux-cheat-sheet-for-penetration-testers/" target="_blank_">Kali Linux Cheat Sheet</a>
- <a href="https://redteamtutorials.com/2018/10/24/msfvenom-cheatsheet/">MSFVenom</a>
- <a href="https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Windows%20-%20Privilege%20Escalation.md">Windows Privelege Escalation</a>
- <a href="https://www.blackhillsinfosec.com/password-spraying-other-fun-with-rpcclient/">Password spraying with RPCClient & SMBClient</a>
- <a href="https://devhints.io/curl">CURL</a>
- <a href="https://www.markdownguide.org/basic-syntax/" target="_blank_">Markdown Syntax</a>