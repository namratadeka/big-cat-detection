function [rgb, pints] = dominantColor(I)
    %I = imread('tiger1.jpg');
    colorTransform = makecform('srgb2lab');
    lab = applycform(I, colorTransform);
    %figure, imshow(lab);
    [countsl,binsl] = imhist(lab(:,:,1));
    [countsa,binsa] = imhist(lab(:,:,2));
    [countsb,binsb] = imhist(lab(:,:,3));
    data = [countsl countsa countsb];
    if isgreater(data(1,:),data(2,:))
        data(1,4) = 1;
    end
    if isgreater(data(256,:),data(255,:))
        data(256,4) = 1;
    end
    for c = 2:255
        if isgreater(data(c,:),data(c-1,:))
            if isgreater(data(c,:),data(c+1,:))
                data(c,4) = 1;
            else
                data(c,4) = 0;
            end
        else
            data(c,4) = 0;
        end
    end
    %finding peaks in histogram
    [pks,peakidx] = findpeaks(data(:,4));
    %spreading peak labels
    labels = zeros(256,1);
    for c = 1:256
        if(~isempty(find(peakidx==c)))
            labels(c,1) = c;
        else
            idx = find(abs(peakidx-c) == min(abs(peakidx-c)));
            if length(idx==1)
                labels(c,1) = peakidx(idx(1),1);
            else
                if isgreater(data(peakidx(idx(1),1),:),data(peakidx(idx(2),1),:))
                    labels(c,1) = peakidx(idx(1),1);
                else
                    labels(c,1) = peakidx(idx(2),1);
                end
            end
        end
    end
    %relabelling
    lname = 1;
    for c = 2:length(labels)
        if labels(c,1) == labels(c-1,1)
            data(c,4) = lname;
            data(c-1,4) = lname;
        else
            lname = lname + 1;
        end
    end
    %forming clusters
    clusters = cell(length(unique(labels)),1);
    for c = 1:length(data)
        clusters{data(c,4)} = [clusters{data(c,4)} c];
    end
    %dominant mean color of each cluster
    domMean = zeros(length(clusters),3);
    for c = 1:length(clusters)
        for i = 1:3
            if sum(data(clusters{c},i))~= 0
                domMean(c,i) = (clusters{c}*data(clusters{c},i))/sum(data(clusters{c},i));
            else
                domMean(c,i) = 0;
            end
        end
    end
    s = size(lab);
    img = zeros(size(lab),'like',lab);
    pints = zeros(s(1),s(2),3);
    for c = 1:3
        for i = 1:s(1)
            for j = 1:s(2)
                inten = lab(i,j,c);
                cl = data(inten+1,4);
                img(i,j,c) = domMean(cl,c);
                pints(i,j,c) = cl;
            end
        end
    end
    %figure, imshow(img);
    cform = makecform('lab2srgb');
    rgb = applycform(img,cform);
    figure, imshow(rgb);
