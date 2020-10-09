# ZkDemo

#### 0.屏幕旋转（仅手动旋转）
#### 1.图像平均算法(图像降噪)
> 实现原理: 将多张图片点对点RGB通道叠加平均
> - 程序过程 :
> - 首先将n张图片转换成char 类型 装进数组.
> - 进行图像矩阵遍历 修改RGB通道的值.首先将n张图片 RGB通道进行累加后除n.达到一个平均值
> - 得到一个RGB平均的矩阵 char 类型 转换成Image
> - 每一个像素点RGB三通道进行处理（还有A通道可忽略）
![像素矩阵](https://github.com/kuiZhang98/ZkDemo/blob/master/%E5%9B%BE%E7%89%87/WechatIMG775.png?raw=true)
