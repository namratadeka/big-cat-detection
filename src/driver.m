I = imread('../data/tiger9.jpg');   %Change location of image here.
I = imresize(I,0.6);
%Estimating statistical prior energy
gmmImg = GMM(I);

%Estimating edge energy
[rgb,pints] = dominantColor(I);
J9 = edgeEnergy(rgb,pints);
edgeImg = im2bw(myContour(I,J9));
We = 6;
Wg = 10;
E = We*edgeImg + Wg*gmmImg;
%E = uint8(E);
th = graythresh(E);
E = im2bw(E,th);
figure,imshow(E);
%opening
se = strel('disk',2,0);
result = imopen(E,se);
figure,imshow(result);

result = bwmorph(result,'remove');
result = bwmorph(result,'thicken');
figure,imshow(result);
rgb = zeros(size(I),'like',I);
rgb(:,:,1) = double(result);
%rgb(:,:,2) = double(result);
%rgb(:,:,3) = double(result);
rgb = 255*rgb;
%c=imfuse(I,rgb,'blend','Scaling','joint');
c = imadd(I,rgb);
figure,imshow(c);