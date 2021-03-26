%Histogram Equalization

%Load original image
ori_im=imread('Fig0334(a)(hubble-original).tif');
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