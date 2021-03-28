# 基于半色调技术的图像打印程序
---
### 实验要求：

下图展示了十种点模式。要求把原图中每一个像素按不同灰度等级映射成一个3*3的点模式。这种打印方式被称为**半色调技术（halftoing）**。 
![点模式.png](https://i.loli.net/2021/03/28/veJyHSqMiErmaxh.png)

注意，由于每一个像素被映射成了一个3*3的区域，因此图像的长和宽会分别变为原来的三倍，分辨率下降到原来的33%。为了防止打印的图像太大，你需要对原图像进行一定的缩放。

1.  基于上述原理，编写程序实现半色调打印。程序必须能够缩放图像，保证打印的凸显不会超过A4大小（8.5*11 inches）。
2.  编写一个程序，产生并使用半色调打印测试图像。该测试图像大小为256*256，第一列全为0，第二列全为1……最后一列全为255。
3.  使用半色调打印教材中的图片2.22(a)。

---
### 实验分析
整个流程分为三步
1. 检查图像尺寸，如果不符条件则缩放。
2. 将图像的灰度级量化为0-9，对应10种点模式
3. 根据点模式打印图片

- **预备知识**：网页打印一般使用96dpi（windows系统）或72dpi（Mac），dpi=像素/英寸，对比A4的尺寸算出在96dpi下图像的最大尺寸为272*352。
- **检查并缩放尺寸**：用`size()`函数获取图像尺寸M*N，获取图片尺寸和最大尺寸之比（长和宽都要），获取这长、宽缩放比例中的最大值作为缩放因子。若缩放因子大于1则需要缩放，使用函数`imresize()`，如；如果小于1则不需要缩放。
- **灰度级量化**：题目需要我们把0-255的灰度量化成十个灰度值来对应10种点模式。也就相当于把**共256个灰度级分成10个单位，每个单位为25.6，观察某个像素含有几个单位即可**。注意，直接用25.6去除得到的是浮点数，需要将其变为正整数才能被使用。**尤其需要注意的是，这里不能使用四舍五入**`round()`，**必须使用向下取整**`floor()`或是`fix()`。比如纯白色的灰度为255，除了25.6之后四舍五入得到的是10，但是我们点模式的编号是0-9，会报错`矩阵超出索引范围`。
- **根据点模式打印图片**：使用for循环，遍历（已量化灰度为0-9）原图中的每一个像素，根据其灰度级将对应的点模式赋值给放大后图片中的一块3*3区域。  
`im_new(indexM*3-2:indexM*3,indexN*3-2:indexN*3)=Dot(:,:,level+1);`  
matlab中若是单独一个`:`，表示全选这整行/整列；若是`a:b`则表示选择从a到b的范围。而每次循环中，打印图片的最后一行/列是原图中索引的3倍。下图以列编号为例，表达了这种关系，注意matlab的序号是从1开始而不是从0开始的。因此可以方便地对整个区域进行赋值，无需使用四重循环，只需用二重循环遍历原图即可。
![draft](https://i.loli.net/2021/03/28/lvcML9Jtpei7A2E.png)

---
### Matlab源码
```matlab
% Image Printing Program Based on Halftoning

% Usually it is safe to set webpage to 96 dpi, so for A4 size the original
% graphic should not larger than 272*352
% 网页打印中，A4的分辨率是96像素/英寸，放大三倍后的图片最大不能超过816*1056
% 即原图不能超过272*352
M_standard=272;
N_standard=352;
ori_im=imread('Fig0222(a)(face).tif');
[M,N]=size(ori_im);


% Scale the image to proper size
% 缩放为正确大小
scale_M=double(M)/M_standard;
scale_N=double(N)/N_standard;
scale_factor=max(scale_M,scale_N);
if scale_factor>1
    ori_im=imresize(ori_im,scale_factor);
    [M,N]=size(ori_im);
end

% Scale the gray levels to 0-9
% 获得灰度级数变为10时的灰度分布
im2=floor(ori_im./25.6);

% Define the dot pattern
% 定义dot pattern
Dot(:,:,1)=zeros(3,3);
Dot(:,:,2)=[0,255,0;0,0,0;0,0,0];
Dot(:,:,3)=[0,255,0;0,0,0;0,0,255];
Dot(:,:,4)=[255,255,0;0,0,0;0,0,255];
Dot(:,:,5)=[255,255,0;0,0,0;255,0,255];
Dot(:,:,6)=[255,255,255;0,0,0;255,0,255];
Dot(:,:,7)=[255,255,255;0,0,255;255,0,255];
Dot(:,:,8)=[255,255,255;0,0,255;255,255,255];
Dot(:,:,9)=[255,255,255;255,0,255;255,255,255];
Dot(:,:,10)=[255,255,255;255,255,255;255,255,255];

% Generate and print the test image
% 生成并转换测试图
test_im=zeros(256,256);
for ii=1:256
    test_im(:,ii)=ii-1;
end
test_im_2=floor(test_im./25.6);
test_im_new=zeros(768,768);
for indexM=1:256
    for indexN=1:256
        level=test_im_2(indexM,indexN);
        test_im_new(indexM*3-2:indexM*3,indexN*3-2:indexN*3)=Dot(:,:,level+1);
    end
end


% Print the image using halftoning
% 打印lena
im_new=zeros(3*size(ori_im));
for indexM=1:M
    for indexN=1:N
        level=im2(indexM,indexN);
        im_new(indexM*3-2:indexM*3,indexN*3-2:indexN*3)=Dot(:,:,level+1);
    end
end

% Display the output images
imshow(ori_im);
figure();
imshow(test_im,[0,255])
figure();
imshow(test_im_new);
figure()
imshow(im_new);

```
---
### 实验结果
- 原图
![lena.png](https://i.loli.net/2021/03/28/JShLZ4vkAGsW2lQ.png)
- 原图的半色调打印结果
![dot lena.png](https://i.loli.net/2021/03/28/kNnVy97SOlaopif.png)
- 测试图
![test.png](https://i.loli.net/2021/03/28/3J4yY6VBIWEOfH5.png)
- 测试图的半色调打印结果
![dot test.png](https://i.loli.net/2021/03/28/SL7ecqu8zDYUyKk.png)
  

