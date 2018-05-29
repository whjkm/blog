---
title: 机器学习实战笔记（四）Logistic回归
date: 2018-05-28 17:24:48
tags: 机器学习 python
categories: 机器学习
---
### Logistic回归
假设现在有一些数据点，我们用一条直线对这些点进行拟合（这条直线称为最佳拟合直线），这个拟合过程就称作回归。利用Logistic回归进行分类的主要思想就是：根据现有的数据对分类边界线建立回归公式，以此进行分类。
### Logistic回归的特点

> 优点：计算代价不高，易于理解和实现。
缺点：容易欠拟合，分类精度可能不高。
适用数据类型：数值型和标称型数据

### Logistic回归的一般过程

 1. 收集数据：采用任意方法收集数据。
 2. 准备数据：由于需要进行距离计算，因此要求数据类型为数值型。另外，结构化数据格式则最佳。
 3. 分析数据：采用任意方法对数据进行分析。
 4. 训练算法：大部分时间将用于训练，训练的目的是为了找到最佳的分类回归系数。
 5. 测试算法：一旦训练步骤完成，分类将会很快。
 6. 使用算法：首先，我们需要输入一些数据，并将其转换成对应的结构化数值；接着，基于训练好的回归系数就可以对这些数值进行简单的回归计算，判定它们属于哪个类别；在这之后，我们就可以在输出的类别上做一些其他分析工作。

### 基于 Logistic 回归和 Sigmoid 函数的分类
#### Sigmoid函数
Sigmoid函数：$g(z) = \frac{1}{1+e^{-z}} $

Sigmoid函数是一种阶跃函数（step function）,当x为0时，Sigmoid函数值为0.5。随着x的增大，对应的Sigmoid值将逼近于1；而随着x的减小，Sigmoid值将逼近于0。如果横坐标刻度足够大， Sigmoid函数看起来很像一个阶跃函数。
#### 最佳回归系数
Logistic回归是回归的一种方法，它利用的是Sigmoid函数阈值在[0,1]这个特性。Logistic回归进行分类的主要思想是：根据现有数据对分类边界线建立回归公式，以此进行分类。其实，Logistic本质上是一个基于条件概率的判别模型(Discriminative Model)。
Sigmoid函数的输入记为z：

$$ z = w_0x_0+w_1x_1+w_2x_2+...+w_nx_n $$

上式可以写成向量形式： $z = w^Tx
$,其中的向量x是分类器的输入数据，向量w也就是我们要找到的最佳参数（系数)。
结合Sigmoid函数:$ h_w(x) = g(w^Tx) = \frac{1}{1+e^{-w^Tx}} $
hw(x)函数的值有特殊的含义，它表示结果取1的概率，因此对于输入x分类结果为类别1和类别0的概率分别为：

$$P(y=1|x;w) = h_w(x)$$

$$P(y=0|x;w) = 1-h_w(x)$$

构造Cost函数为：

$$ Cost(h_w(x),y) = h_w(x)^y(1-h_w(x))^{1-y}$$

将表达式对数化：

$$ Cost(h_w(x),y) = ylogh_w(x) + (1-y)log(1-h_w(x))$$

这个代价函数，是对于一个样本而言的。假定样本与样本之间相互独立，那么整个样本集生成的概率即为所有样本生成概率的乘积，再将公式对数化，基于最大似然估计得：

$$ J(w) = \sum_{i=1}^m[y^{(i)}logh_w(x^{(i)}) + (1-y)^{(i)}log(1-h_w(x^{(i)}))] $$

m为样本的总数，y(i)表示第i个样本的类别，x(i)表示第i个样本，需要注意的是w是多维向量，x(i)也是多维向量。
满足J(w)的最大的w值即是我们需要求解的最佳回归系数。
#### 梯度上升法
梯度上升法基于的思想是：要找到某函数的最大值，最好的方法是沿着该函数的梯度方向探寻。如果梯度记为∇ ，则函数f(x,y)的梯度由下式表示：

$$
∇f(x,y) = \begin{pmatrix}
   \frac{\partial{f(x,y)}}{\partial{x}}\\
   \frac{\partial{f(x,y)}}{\partial{y}}
\end{pmatrix}
$$

梯度上升算法的迭代公式如下：

$$ w:= w+\alpha∇_wf(w)$$

那么，现在我们只要求出J(w)的偏导，就可以利用梯度上升算法，求解J(w)的极大值了。

$$  \frac{\partial{J(w)}}{\partial{w_j}} =        \frac{\partial{J(w)}}{\partial{g(w^Tx)}} *
\frac{\partial{g(w^Tx)}}{\partial{w^Tx}} *
\frac{\partial{w^Tx}}{\partial{w_j}}
$$

$$
\frac{\partial{J(w)}}{\partial{g(w^Tx)}} = y*\frac{1}{g(w^Tx)} + (y-1) * \frac{1}{1-g(w^Tx)}
$$

$$
\frac{\partial{g(w^Tx)}}{\partial{w^Tx}} = g(w^Tx)(1-g(w^Tx))
$$

$$
\frac{\partial{w^Tx}}{\partial{w_j}} = \frac{\partial{J( w_0x_0+w_1x_1+w_2x_2+...+w_nx_n)}}{\partial{w_j}} = x_j
$$

综上所述：

$$
\frac{\partial{J(w)}}{\partial{w_j}} = (y-h_w(x))x_j
$$

梯度上升迭代公式为：

$$
w_j:= w_j + \alpha\sum_{i=1}^m(y^{(i)}-h_w(x^{(i)}))x_j^{(i)}
$$

#### 训练算法
梯度上升法的伪代码如下：
```
每个回归系数初始化为1
重复R次：
   计算整个数据集的梯度
   使用alpha × gradient更新回归系数的向量
   返回回归系数
```
Logistic 回归梯度上升优化算法:
```python
# 读取数据
def loadDataSet():
    dataMat = []
    labelMat = []
    fr = open('H:/python/ml/testSet.txt')
    for line in fr.readlines():
        lineArr = line.strip().split()     #去除回车
        dataMat.append([1.0, float(lineArr[0]), float(lineArr[1])]) #为了计算方便，在每一行添加一个X0 = 1.0
        labelMat.append(int(lineArr[2]))     #添加标签
    fr.close()
    return dataMat, labelMat

#logistic函数，输入可以是向量
def sigmoid(inX):
    return 1.0/(1 + np.exp(-inX))
```
```python
# 梯度上升优化算法
def gradAscent(dataMatIn, classLabels):
    dataMatrix = np.mat(dataMatIn)
    labelMat = np.mat(classLabels).transpose()
    m, n = np.shape(dataMatrix)
    alpha = 0.001           # 移动步长
    maxCycles = 500         # 最大迭代次数
    weights = np.ones((n, 1))          # n行1列，将每个回归系数初始化为1

    # 对公式进行向量化  θ:=θ-α.x'.E
    for k in range(maxCycles):
        h = sigmoid(dataMatrix * weights)    # A=x.θ和g(A)
        error = (labelMat - h)      # E=g(A)-y  训练数据的损失
        weights = weights + alpha * dataMatrix.transpose() * error   # 梯度上升向量化公式
    return weights.getA()  # 将numpy矩阵转换为数组
```
#### 分析数据：画出决策边界
绘制数据之间的分隔线。画出数据集和Logistic回归最佳拟合直线的函数:
```python
#  绘制最佳拟合直线
def plotBestFit(weights):
    dataMat, labelMat = loadDataSet()
    dataArr = np.array(dataMat)             #转换为numpy的array数组
    n = np.shape(dataMat)[0]
    xcord1 = []
    ycord1 = []
    xcord2 = []
    ycord2 = []
    for i in range(n):
        if int(labelMat[i]) == 1:
            xcord1.append(dataArr[i,1])
            ycord1.append(dataArr[i,2])
        else:
            xcord2.append(dataArr[i,1])
            ycord2.append(dataArr[i,2])
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.scatter(xcord1, ycord1, s = 20, c = 'red', marker = 's', alpha = .5)
    ax.scatter(xcord2, ycord2, s = 20, c = 'green', alpha = .5)
    x = np.arange(-3.0, 3.0, 0.1)    #以0.1为步长构造一个-3到3的array
    # w0+w1*x+w2*y=0 => y = (-w0-w1*x)/w2
    y = (-weights[0] - weights[1] * x) / weights[2]
    ax.plot(x, y)   #绘制直线
    plt.title('BestFit')
    plt.xlabel('X1')
    plt.ylabel('X2')
    plt.show()
```
0是两个分类（类别1和类别0）的分界处。因此，我们设定 0 = w0x0 + w1x1 +w2x2，然后解出X2和X1的关系式（即分隔线的方程，注意X0＝1）。
输出的结果如下图所示：
![BestFit][1]

#### 训练算法：随机梯度上升
随机梯度上升算法可以写成如下的伪代码：
```
所有回归系数初始化为1
对数据集中每个样本
    计算该样本的梯度
    使用alpha × gradient更新回归系数值
返回回归系数值
```
用代码实现如下：
```python
# 随机梯度上升算法
def stocGradAscent0(dataMatrix, classLabels):
    m, n = np.shape(dataMatrix)
    alpha = 0.01
    weights = np.ones(n)
    for i in range(m):
        # sum(dataMatrix[i]*weights)为了求 f(x)的值， f(x)=a1*x1+b2*x2+..+nn*xn
        h = sigmoid(sum(dataMatrix[i] * weights))   #h为一个具体的数值
        error = classLabels[i] - h
        weights = weights + alpha * error * dataMatrix[i]
    return  weights
```
改进的随机梯度上升算法：
```python
# 改进的随机梯度上升算法
def stocGradAscent1(dataMatrix, classLabels, numIter = 150):
    m,n = np.shape(dataMatrix)
    weights = np.ones(n)
    # weights_array = np.array([])        # 存储每次更新的回归系数
    for j in range(numIter):
        dataIndex = list(range(m))
        for i in range(m):
            alpha = 4 / (1.0 + j + i) + 0.01      # alpha每次迭代时需要调整, 降低alpha的大小，每次减少1/j+i
            randIndex = int(random.uniform(0, len(dataIndex)))   # 随机选择样本
            h = sigmoid(sum(dataMatrix[randIndex] * weights))
            error = classLabels[randIndex] - h
            weights = weights + alpha * error * dataMatrix[randIndex]
            # weights_array = np.append(weights_array, weights, axis=0)        # 添加回归系数到数组
            del(dataIndex[randIndex])       # 删除已经使用的样本
    return weights
```
对比梯度上升算法主要变化在3个方面：
1.alpha在每次迭代的时候都会调整，虽然alpha会随着迭代次数不断减小，但永远不会减小到0，这是因为公式中还存在一个常数项，必须这样做的原因是为了保证在多次迭代之后新数据仍然具有一定的影响。
2.这里通过随机选取样本来更新回归系数。这种方法将减少周期性的波动。
3.改进算法还增加了一个迭代次数作为第3个参数。如果该参数没有给定的话，算法将默认迭代150次。如果给定，那么算法将按照新的参数值进行迭代。
迭代150次得到的结果如下图所示：
![随机梯度上升][2]

### 从疝气病症预测病马的死亡率
#### 准备数据：处理数据中的缺失值
一些可选的处理数据缺失值的方法：

> 使用可用特征的均值来填补缺失值；
使用特殊值来填补缺失值，如1；
忽略有缺失值的样本；
使用相似样本的均值添补缺失值；
使用另外的机器学习算法预测缺失值。

#### 测试算法：用 Logistic 回归进行分类
Logistic回归分类函数
```python
# logistic回归分类函数
def classifyVector(inX, weights):
    prob = sigmoid(sum(inX*weights))
    if prob > 0.5:
        return 1.0
    else:
        return 0.0

def colicTest():
    frTrain = open('H:/python/ml/horseColicTraining.txt')         #读取训练集
    frTest = open('H:/python/ml/horseColicTest.txt')              #读取测试集
    trainingSet = []
    trainingLabels = []
    for line in frTrain.readlines():
        currLine = line.strip().split('\t')
        lineArr = []
        for i in range(21):
            lineArr.append(float(currLine[i]))
        trainingSet.append(lineArr)
        trainingLabels.append(float(currLine[21]))
    trainWeights = stocGradAscent1(np.array(trainingSet), trainingLabels, 500)   #使用改进的随机梯度下降算法
    #trainWeights = gradAscent(np.array(trainingSet), trainingLabels)
    errorCount = 0
    numTestVec = 0
    for line in frTest.readlines():
        numTestVec += 1.0
        currLine = line.strip().split('\t')
        lineArr = []
        for i in range(21):
            lineArr.append(float(currLine[i]))
        if int(classifyVector(np.array(lineArr), trainWeights)) != int(currLine[21]):
            errorCount += 1
    errorRate = (float(errorCount)/numTestVec)
    print("the error rate of this test is : %f" % errorRate)
    return  errorRate
```
该函数首先导入训练集，同前面一样，数据的最后一列仍然是类别标签。数据最初有三个类别标签，分别代表马的三种情况：“仍存活”、“已经死亡”和“已经安乐死”。这里为了方便，将“已经死亡”和“已经安乐死”合并成“未能存活”这个标签 。

```pythn
# 多次测试结果
def multiTest():
    numTests = 10
    errorSum = 0.0
    for k in range(numTests):
        errorSum += colicTest()
    print("after %d iteration the average error rate is: %f" % (numTests, errorSum/float(numTests)))
```
测试的输出结果如下图所示：
![MutiTest][3]

### 小结
Logistic回归的目的是寻找一个非线性函数Sigmoid的最佳拟合参数，求解过程可以由最优化算法来完成。在最优化算法中，最常用的就是梯度上升算法，而梯度上升算法又可以简化为随机梯度上升算法

### 参考文章
本文的所有源代码和数据文件都可以去[github][4]上下载。
机器学习实战
https://blog.csdn.net/c406495762/article/details/77723333
https://blog.csdn.net/achuo/article/details/51160101
https://blog.csdn.net/c406495762/article/details/77851973
https://blog.csdn.net/v_july_v/article/details/7624837
https://github.com/apachecn/MachineLearning


  [1]: http://p7f8vq3cr.bkt.clouddn.com/Bestfit.PNG
  [2]: http://p7f8vq3cr.bkt.clouddn.com/%E9%9A%8F%E6%9C%BA%E6%A2%AF%E5%BA%A6%E4%B8%8A%E5%8D%87.PNG
  [3]: http://p7f8vq3cr.bkt.clouddn.com/MutiTest.PNG
  [4]: https://github.com/whjkm/MachineLearningInAction-Notebook/tree/master/5.Logistic