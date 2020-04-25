---
layout: page
title: Content
---


### HackTheBox

All walkthroughs are OSCP format i.e no use of the metasploit framework, the exception being msfvenom, or automated exploitation tools.
<ul>
  {% for post in site.categories.HackTheBox %}
  <li>
    <a href="{{ site.github.url }}{{ post.url }}">{{ post.title }}</a>
    <p>{{news.meta}}</p>
  </li>
  {% endfor %}
</ul>
<br>

### Embedded Linux

A series on building a embedded Linux distro from scratch on a RPi 3B.
<ul>
  {% for post in site.categories.rpiembedded reversed %}
  <li>
    <a href="{{ site.github.url }}{{ post.url }}">{{ post.title }}</a>
    <p>{{news.meta}}</p>
  </li>
  {% endfor %}
</ul>
<br>

### Cheatsheets
- <a href="https://www.blackmoreops.com/2016/12/20/kali-linux-cheat-sheet-for-penetration-testers/" target="_blank_">Kali Linux Cheat Sheet</a>
- <a href="https://redteamtutorials.com/2018/10/24/msfvenom-cheatsheet/">MSFVenom</a>
- <a href="https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Windows%20-%20Privilege%20Escalation.md">Windows Privelege Escalation</a>
- <a href="https://www.blackhillsinfosec.com/password-spraying-other-fun-with-rpcclient/">Password spraying with RPCClient & SMBClient</a>
- <a href="https://devhints.io/curl">CURL</a>
- <a href="https://www.markdownguide.org/basic-syntax/" target="_blank_">Markdown Syntax</a>

<!-- original code
<ul class="posts">
  {% for post in site.posts %}

    {% unless post.next %}
      <h3>{{ post.date | date: '%Y' }}</h3>
    {% else %}
      {% capture year %}{{ post.date | date: '%Y' }}{% endcapture %}
      {% capture nyear %}{{ post.next.date | date: '%Y' }}{% endcapture %}
      {% if year != nyear %}
        <h3>{{ post.date | date: '%Y' }}</h3>
      {% endif %}
    {% endunless %}

    <li itemscope>
      <a href="{{ site.github.url }}{{ post.url }}">{{ post.title }}</a>
      <p class="post-date"><span><i class="fa fa-calendar" aria-hidden="true"></i> {{ post.date | date: "%B %-d" }} - <i class="fa fa-clock-o" aria-hidden="true"></i> {% include read-time.html %}</span></p>
    </li>

  {% endfor %}
</ul>
-->
