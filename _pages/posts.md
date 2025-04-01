---
title: "Blog"
permalink: /posts/
layout: archive
author_profile: true
---

<div class="grid__wrapper">
  {% for post in site.posts %}
    <div class="grid__item">
      <article class="archive__item">
        <h2 class="archive__item-title no_toc" itemprop="headline">
          <a href="{{ post.url | relative_url }}" rel="permalink">{{ post.title }}</a>
        </h2>
        
        {% if post.date %}
          <p class="page__meta">
            <i class="far fa-calendar-alt" aria-hidden="true"></i> {{ post.date | date: "%B %d, %Y" }}
            {% if post.read_time %}
              <i class="far fa-clock" aria-hidden="true"></i> {% include read-time.html %}
            {% endif %}
          </p>
        {% endif %}
        
        {% if post.excerpt %}
          <p class="archive__item-excerpt">{{ post.excerpt | markdownify | strip_html | truncate: 160 }}</p>
        {% endif %}
      </article>
    </div>
  {% endfor %}
</div>
