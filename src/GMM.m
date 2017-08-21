function [binaryImage] = GMM(image)
    scale = [3 3 3 1 1];
    classNumber = 2;
    
    [numberRows, numberColumns, depth]=size(image);
    colorTransform = makecform('srgb2lab');
    imageLAB = applycform(image,colorTransform);
    %imageLAB = applycform(image,makecform('srgb2lab'));

    imageLAB = double(imageLAB)/255;

    reshapedImage = reshape(imageLAB(:),numberColumns*numberRows,[]);

    [x,y] = meshgrid(1:numberColumns,1:numberRows);

    x = x(:);
    y = y(:);
    x = x/max(x);
    y = y/max(y);
    %x = x/max(x,[],1);
    %y = y/max(y,[],1);

    featureVector = [reshapedImage x y];
    featureVector = featureVector(:,scale~=0);
    scale = scale(scale~=0);

    featureVector = featureVector - repmat( mean(featureVector,1), length(featureVector), 1);
    featureVector = featureVector./repmat(std(featureVector,1), length(featureVector), 1);

    scale = scale/sum(scale,2)*10;
    featureVector = featureVector.*repmat(scale,size(featureVector,1),1);

    %dimensions = size(featureVector,2);
    options = statset('Display','final','MaxIter',500);
    %options = statset('MaxIter',500);
    gmmFitObject = gmdistribution.fit(featureVector,classNumber,'Regularize',1e-4,'Replicates',1,'Options',options);

    gmmPosterior = posterior(gmmFitObject,featureVector);
    [maxPosterior, classResult] = max(gmmPosterior,[],2);

    labelImage = reshape(classResult,numberRows,numberColumns,[]);
    postImage = reshape(maxPosterior,numberRows,numberColumns,[]);

    finalImage = double(label2rgb(labelImage))/255;
    finalImage(:,:,1) = finalImage(:,:,1).*postImage;
    finalImage(:,:,2) = finalImage(:,:,2).*postImage;
    finalImage(:,:,3) = finalImage(:,:,3).*postImage;

    %figure; imshow(finalImage);

    binaryImage = im2bw(finalImage, 0.5);
    %figure; imshow(binaryImage);

    [counts,bins] = imhist(binaryImage);

    if counts(1)<counts(2)
        binaryImage = imcomplement(binaryImage);
    end
    figure; imshow(binaryImage);
