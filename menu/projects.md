---
layout: page
title: Projects
---


### HackTheBox

All walkthroughs are OSCP format i.e no use of the metasploit framework, the exception being msfvenom, or automated exploitation tools.
<ul>
  {% for news in site.categories.HackTheBox %}
  <li>
    <a href="{{ site.baseurl }}/{{ news.url }}">{{news.title}}</a>
    <p>{{news.meta}}</p>
  </li>
  {% endfor %}
</ul>


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
