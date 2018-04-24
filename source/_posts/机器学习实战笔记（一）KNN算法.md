---
title: 机器学习实战笔记（一）KNN算法
date: 2018-04-24 10:58:27
tags: 机器学习
categories:
---
用python学习机器学习的笔记，所有的代码和实例来源于《机器学习实战》一书。所有源代码和数据都可以在[我的github][1]上下载。
## 1.机器学习基础
机器学习可以分为监督学习和无监督学习，监督学习又可以分为分类和回归，之所以称之为监督学习，是因为这类算法必须知道预测什么，即目标变量的分类信息。与之相对的无监督学习分为聚类和密度估计，此时数据没有类别信息，也不会给定目标值。
## 2.K-近邻算法
k近邻算法就是分类算法的一种。简单地说，k-近邻算法采用测量不同特征值之间的距离方法进行分类。
### 1.特点

> 优点：精度高、对异常值不敏感、无数据输入假定。
缺点：计算复杂度高、空间复杂度高。
适用数据类型：数值型和标称型。

### 2.工作原理

 1. 有一个样本数据集（训练数据集），并且知道其中数据和分类之间的对应关系。(每个数据都存在标签)。
 2. 输入没有标签的新数据之后，将新数据的每个特征和样本集中的数据对应的特征进行比较；然后提取样本数据集中最相似数据的分类标签（距离最近）；一般只选择样本集中前k个最相似的数据（k不等于20）。
 3. 把k个数据标签中出现次数最多的那个分类，作为新数据的分类。

### 3.一般流程

> 收集数据：任何方法。
准备数据：距离计算所需要的数值，最好是结构化的数据格式。
分析数据：一般可采用可视化的方法进行分析。
训练算法：K-近邻算法中不适用。
测试算法：计算错误率。
使用算法：输入样本数据和结构化的输出结果，然后运行k-近邻算法判定输入数据分别属于哪个分类，最后对计算出的分类执行后续处理。

## 3.实例
### 1.使用python导入数据
```python
#创建数据集和标签
def createDataSet():
    group = array([[1.0,1.1],
                  [1.0,1.0],
                  [0,0],
                  [0,0.1]])
    labels = ['A','A','B','B']
    return group, labels
```
###2.KNN算法
使用k-近邻算法将每组数据划分到每个类中：

 1. 计算当前点和测试数据集中的点之间的距离。
 2. 按照距离递增次序排序。
 3. 选取和当前距离最小的k个点。
 4. 计算前k个点的类别出现的频率。
 5. 返回前k个点出现频率最高的类别作为当前预测点的分类。

```python
'''
Parameters:
    inX - 用于分类的数据(测试集)
    dataSet - 用于训练的数据(训练集)
    labes - 训练数据集的label
    k - 选择距离最小的k个点
return：
    sortedClassCount[0][0] - 输入数据的预测分类
'''
# k-近邻算法
def classify0(inX, dataSet, labels, k):
    # 计算距离
    dataSetSize = dataSet.shape[0]
    # 用tile将输入向量复制成和数据集一样大的矩阵
    diffMat = tile(inX, (dataSetSize, 1)) - dataSet
    sqDiffMat = diffMat ** 2
    # 将矩阵的每一行相加，axis = 1表示行相加
    sqDistances = sqDiffMat.sum(axis=1)
    distances = sqDistances ** 0.5
    # 按距离从小到大排序，并返回对应的索引位置
    sortedDistIndicies = distances.argsort()
    
    #创建一个字典，存储标签和出现次数
    classCount = {}
    # 选择距离最小的k个点
    for i in range(k):
        # 查找样本的标签类型
        voteIlabel = labels[sortedDistIndicies[i]]
        # 在字典中给找到的样本标签类型+1
        classCount[voteIlabel] = classCount.get(voteIlabel, 0) + 1
        # 排序并返回出现次数最多的标签类型
        sortedClassCount = sorted(classCount.items(),key=operator.itemgetter(1), reverse=True)
        return sortedClassCount[0][0]
```
### 3.优化约会网站的配对效果
准备数据：从文本文件中解析数据，数据存放在文本文件[datingTestSet2.txt][2]中，在将文本中的数据输入到分类器之前，必须将待处理数据的格式转化为分类器可以接受的格式。
```python
#将文本记录转化为NumPy矩阵
def file2matrix(filename):
    fr = open(filename,'r')
    #获取文件数据行的行数
    numberOfLines = len(fr.readlines())
    #生成一个0矩阵
    returnMat = zeros((numberOfLines,3))
    #要返回的标签
    classLabelVector = []
    fr = open(filename, 'r')
    index = 0
    #解析文件数据到列表
    for line in fr.readlines():
        # 去除字符串首尾的空格
        line = line.strip()
        #用制表符\t分割字符串
        listFormLine = line.split('\t')
        #每列的属性数据
        returnMat[index] = listFormLine[0:3]
        #每列的label标签数据,-1最后一列
        classLabelVector.append(int(listFormLine[-1]))
        index += 1
    return  returnMat,classLabelVector
```
使用Matplotlib画图，分析数据的特征。
```python
# 使用Matplotlib画二维散点图
def draw():
    import matplotlib
    import matplotlib.pyplot as plt
    fig = plt.figure()
    ax = fig.add_subplot(111)
    datingDataMat, datingLabels = file2matrix("datingTestSet2.txt")
    ax.scatter(datingDataMat[:,1], datingDataMat[:,2])
    #ax.scatter(datingDataMat[:,1], datingDataMat[:,2], 15.0*array(datingLabels), 15,0*array(datingLabels))
    plt.show()
```
![Matplotlib画图][3]
如果给的数据的权重不一致，就需要进行归一化操作，归一化特征值，消除特征之间量级不同导致的影响。
这里采用的是线性函数转换：y=(x-MinValue)/(MaxValue-MinValue)。　
```python
#归一化特征值
def autoNorm(dataSet):
    #每列的最小值
    minVals = dataSet.min(0)
    #每列的最大值
    maxVals = dataSet.max(0)
    #归一化处理的范围
    ranges = maxVals - minVals
    normDataSet = zeros(shape(dataSet))
    m = dataSet.shape[0]
    #生成与最小值之差组成的矩阵
    normDataSet = dataSet - tile(minVals,(m,1))
    #最小值之差除以最大值和最小值的差值
    normDataSet = normDataSet / tile(ranges,(m,1))
    # norm_dataset = (dataset - minvalue) / ranges
    return  normDataSet, ranges, minVals
```
测试算法：首先使用了file2matrix和autoNorm()函数从文件中读取数据并将其转换为归一化特征值。接着计算测试向量的数量，此步决定了normMat向量中哪些数据用于测试，哪些数据用于分类器的训练样本；然后将这两部分数据输入到原始kNN分类器函数classify0。
```python
#测试算法
def datingClassTest():
    #测试范围，一部分测试一部分作为样本
    hoRatio = 0.1
    #加载数据
    datingDataMat, datingLabels = file2matrix("datingTestSet2.txt")
    #归一化数据
    normMat, ranges, minVals = autoNorm(datingDataMat)
    #数据的行数
    m = normMat.shape[0]
    #设置样本的测试数据
    numTestVecs = int(m * hoRatio)
    print('numTestVecs', numTestVecs)
    #分类错误数
    errorCount = 0
    #numTestVecs: m表示训练样本的数量
    for i in range(numTestVecs):
        classifierResult = classify0(normMat[i], normMat[numTestVecs : m], datingLabels[numTestVecs : m], 3)
        print("the classifier came back with: %d, the real answer is : %d" %(classifierResult, datingLabels[i]))
        errorCount += classifierResult != datingLabels[i]
    print("the total error rate is :%f" %(errorCount / numTestVecs))
    print(errorCount)
```
### 4.手写识别系统
构造一个能识别数字 0 到 9 的基于 KNN 分类器的手写数字识别系统。
需要识别的数字是存储在文本文件中的具有相同的色彩和大小：宽高是 32 像素 * 32 像素的黑白图像。

目录 [trainingDigits][4] 中包含了大约 2000 个例子，每个例子内容如下图所示，每个数字大约有 200 个样本；目录 testDigits 中包含了大约 900 个测试数据。

```python
#将图像数据转换为向量
def img2vector(filename):
    returnVect = zeros((1, 1024))
    fr = open(filename, 'r')
    for i in range(32):
        lineStr = fr.readline()
        for j in range(32):
            returnVect[0, 32 * i + j] = int(lineStr[j])
    return returnVect
```

```python
def handwritingClassTest():
    #导入数据
    hwLabels = []
    trainingFileList = os.listdir('.../2.KNN/trainingDigits')
    m = len(trainingFileList)
    trainingMat = zeros((m, 1024))
    for i in range(m):
        #从文件名解析分类数字
        fileNameStr = trainingFileList[i]
        fileStr = fileNameStr.split('.')[0]
        classNumStr = int(fileStr.split('_')[0])
        hwLabels.append(classNumStr)
        trainingMat[i] = img2vector('.../2.KNN/trainingDigits/%s' % fileNameStr)

    #导入测试数据
    testFileList = os.listdir('.../2.KNN/testDigits')
    errorCount = 0
    mTest = len(testFileList)
    for i in range(mTest):
        fileNameStr = testFileList[i]
        fileStr = fileNameStr.split('.')[0]
        classNumStr = int(fileStr.split('_')[0])
        vectorUnderTest = img2vector('.../2.KNN/testDigits/%s' % fileNameStr)
        classifierResult = classify0(vectorUnderTest, trainingMat, hwLabels, 3)
        print("the classifier came back with: %d, the real answer is: %d" %(classifierResult, classNumStr))
        errorCount += classifierResult != classNumStr
    print("\nthe total number of errors is: %d" % errorCount)
    print("\nthe total error rate is: %f" %(errorCount / mTest))
```
## 4.小结
   k-近邻算法是分类数据最简单最有效的算法，k-近邻算法必须保存全部数据集，如果训练数据集的很大，必须使用大量的存储空间。此外，由于必须对数据集中的每个数据计算距离值，实际使用时可能非常耗时。k-近邻算法的另一个缺陷是它无法给出任何数据的基础结构信息，因此我们也无法知晓平均实例样本和典型实例样本具有什么特征。
## 参考的文章：
https://blog.csdn.net/c406495762/article/details/75172850
https://github.com/apachecn/MachineLearning/blob/master/docs/2.k-%E8%BF%91%E9%82%BB%E7%AE%97%E6%B3%95.md
http://www.pythoner.com/238.html
《机器学习实战》


  [1]: https://github.com/whjkm/MachineLearningInAction-Notebook
  [2]: https://github.com/whjkm/MachineLearningInAction-Notebook/blob/master/2.KNN/datingTestSet2.txt
  [3]: http://p7f8vq3cr.bkt.clouddn.com/knn.png
  [4]: https://github.com/whjkm/MachineLearningInAction-Notebook/tree/master/2.KNN