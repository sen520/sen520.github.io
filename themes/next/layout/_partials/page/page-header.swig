<header class="post-header">

<{%- if theme.seo %}h2{% else %}h1{%- endif %} class="post-title" itemprop="name headline">
  {{- page.title -}}
  {% include '../post-edit.swig' %}
</{%- if theme.seo %}h2{% else %}h1{%- endif %}>

<div class="post-meta">
  {%- if page.description %}
    <div class="post-description">{{ page.description }}</div>
  {%- endif %}
  {% include 'breadcrumb.swig' %}
</div>

</header>
<script>
(function(){
    var bp = document.createElement('script');
    var curProtocol = window.location.protocol.split(':')[0];
    if (curProtocol === 'https') {
        bp.src = 'https://zz.bdstatic.com/linksubmit/push.js';
    }
    else {
        bp.src = 'http://push.zhanzhang.baidu.com/push.js';
    }
    var s = document.getElementsByTagName("script")[0];
    s.parentNode.insertBefore(bp, s);
})();
</script>