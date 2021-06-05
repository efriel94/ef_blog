---
layout: page
title: Posts
---

<br>
<ul>
{% for post in site.posts %}
  {% assign currentdate = post.date | date: "%B %Y" %}
  {% if currentdate != date %}
    <h2>{{ currentdate }}</h2>
    {% assign date = currentdate %} 
  {% endif %}
    <li><a href="{{ post.url }}">{{ post.title }}</a></li>
{% endfor %}
</ul>
