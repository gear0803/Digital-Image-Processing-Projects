# 直方图均衡的matlab实现以及关于直方图均衡的思考

test

---

先放matlab代码

```matlab
%Histogram Equalization

%Load original image
ori_im=imread('..\original images\Fig0316(4)(bottom_left).tif');
figure();
subplot(2,2,1);
imshow(ori_im);

%Number of gray scales
L=256;  
%Size of the original image
[LEN,WIDTH]=size(ori_im);   

%Histogram of the original image
H=imhist(ori_im);   

%Get the transform funtion
fun=zeros(L,1);   
for index= 1:L
    fun(index,1)=sum(H(1:index));
end
fun=fun./(LEN*WIDTH);
fun=fun.*(L-1);
fun=round(fun);


%New histogram
H_new=zeros(L,1);
for index2= 1:L
   if(fun(index2,1)==0)
       continue;
   else
   H_new(fun(index2,1),1)=H_new(fun(index2,1),1)+H(index2,1);
   end
end

%New image
im2=histeq(ori_im,H_new);
subplot(2,2,2);
imshow(histeq(im2));

%Compare the histogram
subplot(2,2,3);
imhist(ori_im);
subplot(2,2,4);
imhist(im2);
```

---

###结果分析

测试图1：
![Fig0316(4)(bottom_left).tif](https://z3.ax1x.com/2021/03/25/6XcHY9.png)

测试图2：
![Fig0354(a)(einstein_orig).tif](https://z3.ax1x.com/2021/03/25/6Xg0pR.png)



  从增强对比度这一点来看，测试图2的效果显著差于测试图1  

  推测原因是，图1原图的直方图分布很均匀，而图2有非常明显的一个集中的峰。**在均衡的过程中，图2集中的大峰不得不被拆成几个分散的、相隔一定距离的小峰。表现在图片上，则是图中大部分发灰的点为了增大对比度而表现出了明暗，部分成为更深邃的阴影，部分成为发白的噪点。**  
    
  并且，为了保持原来各个bin之间的相对明暗关系，大峰拆分必然导致它会“挤开”原来分布于左右两边的其他点。例如图2的120-180附近的那排矮峰，在直方图均衡后被挤到了几乎最右端。表现在图上则是原图中人物偏灰的白发在经过直方图均衡之后白得发亮了……

  这可能表明，通过直方图均衡来增强对比度的方式只适用于直方图分布比较均匀、且图片中的灰度也分布得比较均匀的情况。对于图2，它出现了那么多发白的噪点，客观来说对比度确实是显著增强了，但是它看起来效果很差，是因为它没有按照人们所想的方式增强对比度。  

  一个更极端的例子：
  ![Fig0334(a)(hubble-original).tif](https://z3.ax1x.com/2021/03/26/6jhFBt.png)
    
  这张图的直方图更加集中了，因此直方图均衡后的效果也更加惨不忍睹，原图中大片黑色的背景为了表现出对比度，不得不产生灰度各异的色块……  

  对于测试图2和3，若想增强对比度，正确的做法应该是使用直方图拉伸函数：imadjust,该函数把原来的直方图“横向拉伸”到更广的范围，增强了对比度。
  ```matlab
  >> help imadjust
imadjust - Adjust image intensity values or colormap

    This MATLAB function maps the intensity values in grayscale image I to new
    values in J such that 1% of data is saturated at low and high intensities of I.

    J = imadjust(I)
    J = imadjust(I,[low_in; high_in],[low_out; high_out])
    J = imadjust(I,[low_in; high_in],[low_out; high_out],gamma)
    newmap = imadjust(map,[low_in; high_in],[low_out; high_out],gamma)
    RGB2 = imadjust(RGB1,___)
    gpuarrayB = imadjust(gpuarrayA,___)

    另请参阅 brighten, gpuArray, histeq, stretchlim
  ```

测试图2使用直方图拉伸处理的结果如下：
![Fig0354(a)(einstein_orig).tif](https://z3.ax1x.com/2021/03/26/6j7vqJ.png)

这正是我们期望的结果。  
  
个人感觉，直方图均衡（或直方图标准化）的主要目的并不在于增强对比度。对比度增强本质上就是直方图左右扩展了，而这又是直方图均衡过程中必然产生的结果。“大峰”削成“矮峰”，削掉的部分必定会分配到左右两边，原来两边的其他峰又被挤到更边上，整体来看灰度范围确实是拉伸了。如果原来的直方图各个bin之间的高矮没有那么夸张，均衡后的效果也会更自然，同时对比度也增强了。（测试图1）  

因此，直方图均衡的主要目的还是在均衡上，是为了直方图规定化服务的，对比度的增强是副产物。若是只想增强对比度不妨考虑更简单的直方图拉伸。