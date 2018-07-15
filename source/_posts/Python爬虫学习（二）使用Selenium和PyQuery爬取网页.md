---
title: Python爬虫学习（二）使用Selenium和PyQuery爬取网页
date: 2018-07-15 20:48:35
tags: python
categories: 爬虫
---
## 1.概述：
使用Selenium模拟浏览器访问网页，利用PyQuery库解析获取到的网页，然后将获取到的信息保存到MongoDB数据库中，这里以淘宝为例，提取商品的信息。
## 2.准备工作：
### 安装MongoDB
现在最新版是4.0，直接去官网下载，然后一直默认安装就可以用了。具体安装过程可以参考下面的两篇博客。
https://blog.csdn.net/Dorma_Bin/article/details/80851230
https://blog.csdn.net/shu15121856/article/details/80736092
然后测试是否可用，4.0之后，默认就开启了系统服务，不用手动配置到服务了。
### 安装Robomongo
Robomongo是mongodb的一个图形化工具，可以很方便的查看存取的数据信息。
![robomongo][1]
## 3.分析网页
在相关的环境配置好了之后，我们就可以来分析需要爬取的页面。以搜索python关键词为例。
![淘宝1][2]
可以看到它的请求链接中包含了几个GET参数，如果要想构造Ajax链接，直接请求再好不过了，它的返回内容是JSON格式，直接爬取相对比较繁琐，这里采用selenium模拟浏览器。
![淘宝2][3]
我们需要获取的是商品信息，打开一个商品，查看它的源代码结构是怎样的。以下面这个商品为例。
![python商品][4]
我们需要从中提取出商品的基本信息，包括商品图片、名称、价格、购买人数、店铺名称和店铺所在地。它的源代码如下图所示：
![商品源码][5]
## 4.模拟搜索
网页分析完毕后，通过代码来实现它。首先selenium模拟浏览器打开淘宝页面，这里创建了一个`webdriver`对象,用来打开Chrome浏览器，等待加载时，我们使用了`WebDriverWait`对象，它可以指定等待条件，同时指定一个最长等待时间，这里指定为最长10秒。如果在这个时间内成功匹配了等待条件，也就是说页面元素成功加载出来了，就立即返回相应结果并继续向下执行，否则到了最大等待时间还没有加载出来时，就直接抛出超时异常。
`presence_of_element_located`这个条件,用来判断商品的信息是否加载出来，从网页的源码中得到，搜索框的标签是`#q`,通过CSS选择器，选中搜索框的标签，搜索按钮的标签为`#J_TSearchForm > div.search-button > button`,然后将需要搜索的关键词输入到输入框中。

```python
import re
from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from pyquery import PyQuery as pq

KEYWORD = 'Python'
browser = webdriver.Chrome()
wait = WebDriverWait(browser, 10)

# 搜索索引页面，用selenium控制自动搜索
def search():
    try:
        browser.get('https://www.taobao.com')
        # 等待元素信息加载完成
        input = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, '#q')))
        submit = wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, '#J_TSearchForm > div.search-button > button')))
        input.send_keys(KEYWORD)   # 传入需要搜索的关键词
        submit.click()
        total = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, '#mainsrp-pager > div > div > div > div.total')))
        get_products()
        return total.text
    except TimeoutException:
        return search()
```
## 5.读取多个页面
这里只是一个页面的结果，我们还需要设置一个自动翻页，读取多个页面的数据。如下图所示：
![下一页][6]
```python
# 跳转到下一个页面
def next_page(page_number):
    try:
        input = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, '#mainsrp-pager > div > div > div > div.form > input')))
        submit = wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, '#mainsrp-pager > div > div > div > div.form > span.btn.J_Submit')))
        input.clear()
        input.send_keys(page_number)
        submit.click()
        wait.until(EC.text_to_be_present_in_element((By.CSS_SELECTOR, '#mainsrp-pager > div > div > div > ul > li.item.active > span'), str(page_number)))
        get_products()
    except TimeoutException:
        next_page(page_number)
```
这里和上面实现的搜索页面功能类似，通过控制下一页按钮，进行页面的跳转，在页面源码中找到页面输入框的标签`#mainsrp-pager > div > div > div > div.form > input`，页面跳转确定按钮标签`#mainsrp-pager > div > div > div > div.form > span.btn.J_Submit`。然后判断页面是否跳转成功，所在的页面会进行高亮显示，通过这个标签判断是否高亮`#mainsrp-pager > div > div > div > ul > li.item.active > span`。

## 6.解析商品列表
首先判断商品页面是否加载完毕，商品信息所在的标签`#mainsrp-itemlist .items .item`,然后通过调用`page_source`属性获取页码的源代码,用PyQuery解析页面。利用CSS选择器，匹配整个页面的每个商品，将结果保存到`items`中，然后再对`items`进行遍历，利用`find（）`方法找到我们想要的信息。
```python
# 解析商品页
def get_products():
    wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, '#mainsrp-itemlist .items .item')))
    html = browser.page_source      # 获取页面的源代码
    doc = pq(html)
    items = doc('#mainsrp-itemlist .items .item').items()
    for item in items:
        product = {
            'image': item.find('.pic .img').attr('src'),
            'price': item.find('.price').text().replace('\n', ''),
            'deal': item.find('.deal-cnt').text()[:-3],
            'title': item.find('title').text(),
            'shop': item.find('.shop').text(),
            'location': item.find('.location').text()
        }
        print(product)
        save_to_mongo(product)
```

## 7.保存到MongoDB
这里首先创建了一个MongoDB的连接对象,说明需要插入的数据库，直接`insert()`方法将数据插入MongoDB中。

```python
MONGO_URL = 'localhost'
MONGO_DB = 'taobao'
MONGO_TABLE = 'product'

client = pymongo.MongoClient(MONGO_URL)
db = client[MONGO_DB]
# 保存到数据库
def save_to_mongo(result):
    try:
        if db[MONGO_TABLE].insert(result):
            print('存储到MONGODB成功', result)
    except Exception:
        print('存储到MONGODB失败', result)

```
运行结果如下图所示：
![最终结果][7]


## 完整代码
```python
import re
from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from pyquery import PyQuery as pq
# from config import *
import pymongo

MONGO_URL = 'localhost'
MONGO_DB = 'taobao'
MONGO_TABLE = 'product'

KEYWORD = 'Python'
client = pymongo.MongoClient(MONGO_URL)   # 创建一个连接对象 
db = client[MONGO_DB]
# browser = webdriver.Chrome()

# Chrome Headless模式
chrome_options = webdriver.ChromeOptions()
chrome_options.add_argument('--headless')
browser = webdriver.Chrome(chrome_options=chrome_options)
wait = WebDriverWait(browser, 10)


# 搜索索引页面，用selenium控制自动搜索
def search():
    try:
        browser.get('https://www.taobao.com')
        # 等待元素信息加载完成
        input = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, '#q')))
        submit = wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, '#J_TSearchForm > div.search-button > button')))
        input.send_keys(KEYWORD)   # 传入需要搜索的关键词
        submit.click()
        total = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, '#mainsrp-pager > div > div > div > div.total')))
        get_products()
        return total.text
    except TimeoutException:
        return search()

# 跳转到下一个页面
def next_page(page_number):
    try:
        input = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, '#mainsrp-pager > div > div > div > div.form > input')))
        submit = wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, '#mainsrp-pager > div > div > div > div.form > span.btn.J_Submit')))
        input.clear()
        input.send_keys(page_number)
        submit.click()
        wait.until(EC.text_to_be_present_in_element((By.CSS_SELECTOR, '#mainsrp-pager > div > div > div > ul > li.item.active > span'), str(page_number)))
        get_products()
    except TimeoutException:
        next_page(page_number)

# 解析商品页
def get_products():
    wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, '#mainsrp-itemlist .items .item')))
    html = browser.page_source      # 获取页面的源代码
    doc = pq(html)
    items = doc('#mainsrp-itemlist .items .item').items()
    for item in items:
        product = {
            'image': item.find('.pic .img').attr('src'),
            'price': item.find('.price').text().replace('\n', ''),
            'deal': item.find('.deal-cnt').text()[:-3],
            'title': item.find('title').text(),
            'shop': item.find('.shop').text(),
            'location': item.find('.location').text()
        }
        print(product)
        save_to_mongo(product)

# 保存到数据库
def save_to_mongo(result):
    try:
        if db[MONGO_TABLE].insert(result):
            print('存储到MONGODB成功', result)
    except Exception:
        print('存储到MONGODB失败', result)


def main():
    try:
        total = search()
        # 通过正则表达式提取页面的总页数
        total = int(re.compile('(\d+)').search(total).group(1))
        # print(total)
        # 遍历所有页面
        for i in range(2, total+1):
            next_page(i)
    except Exception:
        print("出错啦")
    finally:
        browser.close()

if __name__ == "__main__":
    main()
```


  [1]: http://p7f8vq3cr.bkt.clouddn.com/Robomongo.PNG
  [2]: http://p7f8vq3cr.bkt.clouddn.com/taobao1.PNG
  [3]: http://p7f8vq3cr.bkt.clouddn.com/taobao2.PNG
  [4]: http://p7f8vq3cr.bkt.clouddn.com/python%E5%95%86%E5%93%81.PNG
  [5]: http://p7f8vq3cr.bkt.clouddn.com/%E5%95%86%E5%93%81%E6%BA%90%E7%A0%81.PNG
  [6]: http://p7f8vq3cr.bkt.clouddn.com/%E4%B8%8B%E4%B8%80%E9%A1%B5.PNG
  [7]: http://p7f8vq3cr.bkt.clouddn.com/%E6%9C%80%E7%BB%88%E7%BB%93%E6%9E%9C.PNGhttp://p7f8vq3cr.bkt.clouddn.com/%E6%9C%80%E7%BB%88%E7%BB%93%E6%9E%9C.PNG