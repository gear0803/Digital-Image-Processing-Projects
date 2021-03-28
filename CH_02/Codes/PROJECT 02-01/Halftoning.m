%Image Printing Program Based on Halftoning

%Usually it is safe to set webpage to 96 dpi, so for A4 size the original
%graphic should not larger than 272*352
%��ҳ��ӡ�У�A4�ķֱ�����96����/Ӣ�磬�Ŵ��������ͼƬ����ܳ���816*1056
%��ԭͼ���ܳ���272*352
M_standard=272;
N_standard=352;
ori_im=imread('Fig0222(a)(face).tif');
[M,N]=size(ori_im);


%Scale the image to proper size
%����Ϊ��ȷ��С
scale_M=double(M)/M_standard;
scale_N=double(N)/N_standard;
scale_factor=max(scale_M,scale_N);
if scale_factor>1
    ori_im=imresize(ori_im,scale_factor);
    [M,N]=size(ori_im);
end

%Scale the gray levels to 0-9
%��ûҶȼ�����Ϊ10ʱ�ĻҶȷֲ�
im2=floor(ori_im./25.6);

%Define the dot pattern
%����dot pattern
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

%Generate and print the test image
%���ɲ�ת������ͼ
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


%Print the image using halftoning
%��ӡlena
im_new=zeros(3*size(ori_im));
for indexM=1:M
    for indexN=1:N
        level=im2(indexM,indexN);
        im_new(indexM*3-2:indexM*3,indexN*3-2:indexN*3)=Dot(:,:,level+1);
    end
end

%Display the output images
imshow(ori_im);
figure();
imshow(test_im,[0,255])
figure();
imshow(test_im_new);
figure()
imshow(im_new);