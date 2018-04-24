{% extends '_layout.swig' %}
{% import '_macro/post.swig' as post_template %}
{% import '_macro/sidebar.swig' as sidebar_template %}


{% block title %} {{ page.title }} | {{ config.title }} {% endblock %}

{% block page_class %}page-post-detail{% endblock %}


{% block content %}

  <div id="posts" class="posts-expand">
    {{ post_template.render(page) }}

    <div class="post-spread">
      {% if theme.jiathis %}
        {% include '_partials/share/jiathis.swig' %}
      {% elseif theme.baidushare %}
        {% include '_partials/share/baidushare.swig' %}
      {% elseif theme.add_this_id %}
        {% include '_partials/share/add-this.swig' %}
      {% elseif theme.duoshuo_shortname and theme.duoshuo_share %}
        {% include '_partials/share/duoshuo_share.swig' %}
      {% endif %}
    </div>
		   <div id="container"> </div>
               <link rel="stylesheet" href="https://imsun.github.io/gitment/style/default.css">
                <script src="https://imsun.github.io/gitment/dist/gitment.browser.js"></script>
                <script>
                var gitment = new Gitment({
					  id: '页面 ID', // 可选。默认为 location.href
					  owner: 'whjkm',
					  repo: 'whjkm.github.io',
					  oauth: {
						client_id: '714965cedbb13275b08e',
						client_secret: '13f9ca22b3b0f4fb90efddf8bc9ba6b2a46a8439',
						},
						})
						gitment.render('container')
				</script>
  </div>

{% endblock %}

{% block sidebar %}
  {{ sidebar_template.render(true) }}
{% endblock %}


{% block script_extra %}
  {% include '_scripts/pages/post-details.swig' %}
{% endblock %}
