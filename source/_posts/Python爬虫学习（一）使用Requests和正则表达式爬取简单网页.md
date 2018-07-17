---
title: Python爬虫学习（一）使用Requests和正则表达式爬取简单网页
date: 2018-06-29 09:17:32
tags: [python, requests, 正则表达式] 
categories: 爬虫
---
## 1.概述
使用Requests库和正则表达式爬取[猫眼电影TOP100][1]中的电影信息，包括电影名称、主演、上映时间、评分、图片等信息。然后将获取的信息保存到文本文件。
## 2.网页分析
要爬取的网页为猫眼电影TOP100（http://maoyan.com/board/4），网页页面如下所示：
![猫眼TOP100][2]
看一下页面的显示规律是怎样的，一页是显示10部电影名称。第二页的url和内容如下所示：url为：http://maoyan.com/board/4?offset=10，可以看出和第一页的url的主要差别为后面的offset，要抓取后面的网页的内容，只要在url后面加上相应的offset参数就可以了。
![第二页][3]

## 3.请求网页
首先请求一个页面，通过requests中的get方法，请求网页。
```python
# 获取单个页面
def get_one_page(url):
    try:
        # 添加头部信息
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.162 Safari/537.36'
        }
        response = requests.get(url, headers=headers)
        # 进行状态码判断，是否正确读取到网页
        if response.status_code == 200:
            return response.text
        return None
    except RequestException:
        return None
```
测试是否成功获取到网页的页面信息。
```python
def main():
    url = 'http://maoyan.com/board/4'
    html = get_one_page(url)
    print(html)
```
## 3.正则表达式
获取到网页的信息之后，就需要用正则表达式来解析网页，抓取我们所需要的信息；打开浏览器的审查元素功能，查看网页的源码，查找我们需要抓取的信息在哪个位置。
![TOP100源码][4]
以第一个电影为例：分析源码。可以看到我们所需要的信息都包含在下面的html代码中。
```html
    <dd>
    <i class="board-index board-index-1">1</i>
    <a href="/films/1203" title="霸王别姬" class="image-link" data-act="boarditem-click" data-val="{movieId:1203}">
    <img src="//ms0.meituan.net/mywww/image/loading_2.e3d934bf.png" alt="" class="poster-default" />
    <img data-src="http://p1.meituan.net/movie/20803f59291c47e1e116c11963ce019e68711.jpg@160w_220h_1e_1c" alt="霸王别姬" class="board-img" />
    </a>
    <div class="board-item-main">
      <div class="board-item-content">
              <div class="movie-item-info">
        <p class="name"><a href="/films/1203" title="霸王别姬" data-act="boarditem-click" data-val="{movieId:1203}">霸王别姬</a></p>
        <p class="star">
                主演：张国荣,张丰毅,巩俐
        </p>
<p class="releasetime">上映时间：1993-01-01(中国香港)</p>    </div>
    <div class="movie-item-number score-num">
<p class="score"><i class="integer">9.</i><i class="fraction">6</i></p>        
    </div>

      </div>
    </div>

  </dd>
```
一个电影的信息都包含在`<dd>`标签中，我们需要从中抓取图片、名称、主演、上映时间、评分等信息。通过正则表达式来实现：
```python
# 解析网页
def parse_one_page(html):
    pattern = re.compile('<dd>.*?board-index.*?>(\d+)</i>.*?src="(.*?)".*?name"><a'
                         +'.*?>(.*?)</a>.*?star">(.*?)</p>.*?releasetime">(.*?)</p>'
                         +'.*?integer">(.*?)</i>.*?fraction">(.*?)</i>.*?</dd>', re.S)
    items = re.findall(pattern, html)
    # print(items)
    for item in items:
        yield {
            'index': item[0],
            'image': item[1],
            'title': item[2],
            'actor': item[3].strip()[3:],
            'time': item[4].strip()[5:],
            'score': item[5] + item[6]
        }
```
```python
'<dd>.*?board-index.*?>(\d+)</i>.*?src="(.*?)".*?name"><a'
+'.*?>(.*?)</a>.*?star">(.*?)</p>.*?releasetime">(.*?)</p>'
+'.*?integer">(.*?)</i>.*?fraction">(.*?)</i>.*?</dd>'
```
这串字符串就是我们用到的正则表达式，先从`<dd>`标签开始进行匹配，首先匹配的`board-index`，表示是电影的排名信息，用非贪婪匹配来提取i节点中的信息；接下来匹配图片的链接信息，保存在`src`标签中，然后通过`name`属性匹配电影的名称，再去`p`标签中查找`star`属性，得到主演的信息，后面接着获取`releasetime`发行时间和评分的信息。

## 4.保存
正则表达式写好之后，可以先测试输出一下，看得到的是否是我们想要的信息，如果信息无误就把信息用文本保存下来。
这里通过`JSON`库的`dumps()`方法实现字典的序列化，并指定`ensure_ascii`参数为`False`，这样可以保证输出结果是中文形式而不是`Unicode`编码。
```python
# 将抓取的内容保存到文件
def write_to_file(content):
    with open('result.txt', 'a', encoding='utf-8') as f:
        f.write(json.dumps(content, ensure_ascii=False) + '\n')
        f.close()
```

## 完整代码
完整的python代码如下，后面使用`Pool`进程池，多进程来提升代码的抓取效率。
```python
import requests
from requests.exceptions import RequestException
import re
import json
from multiprocessing import Pool

# 获取单个页面
def get_one_page(url):
    try:
        # 添加头部信息
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.162 Safari/537.36'
        }
        response = requests.get(url, headers=headers)
        # 进行状态码判断，是否正确读取到网页
        if response.status_code == 200:
            return response.text
        return None
    except RequestException:
        return None

# 解析网页
def parse_one_page(html):
    pattern = re.compile('<dd>.*?board-index.*?>(\d+)</i>.*?src="(.*?)".*?name"><a'
                         +'.*?>(.*?)</a>.*?star">(.*?)</p>.*?releasetime">(.*?)</p>'
                         +'.*?integer">(.*?)</i>.*?fraction">(.*?)</i>.*?</dd>', re.S)
    items = re.findall(pattern, html)
    # print(items)
    for item in items:
        yield {
            'index': item[0],
            'image': item[1],
            'title': item[2],
            'actor': item[3].strip()[3:],
            'time': item[4].strip()[5:],
            'score': item[5] + item[6]
        }

# 将抓取的内容保存到文件
def write_to_file(content):
    with open('result.txt', 'a', encoding='utf-8') as f:
        f.write(json.dumps(content, ensure_ascii=False) + '\n')
        f.close()

def main(offset):
    url = 'http://maoyan.com/board/4?offset=' + str(offset)
    html = get_one_page(url)
    # print(html)
    # parse_one_page(html)
    for item in parse_one_page(html):
        print(item)
        write_to_file(item)

if __name__ == '__main__':
    pool = Pool()
    pool.map(main, [i*10 for i in range(10)])
    # for i in range(10):
      # main(i*10)

```
最终运行结果如下：
![运行结果][5]


  [1]: http://maoyan.com/board/4
  [2]: http://p7f8vq3cr.bkt.clouddn.com/%E7%8C%AB%E7%9C%BCTOP100.PNG
  [3]: http://p7f8vq3cr.bkt.clouddn.com/%E7%AC%AC%E4%BA%8C%E9%A1%B5.PNG
  [4]: http://p7f8vq3cr.bkt.clouddn.com/TOP100%E6%BA%90%E7%A0%81.PNG
  [5]: http://p7f8vq3cr.bkt.clouddn.com/%E8%BF%90%E8%A1%8C%E7%BB%93%E6%9E%9C.PNG