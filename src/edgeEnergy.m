function J = edgeEnergy(rgb, pints)
    comb = combvec(unique(pints(:,:,2))', unique(pints(:,:,3))');
    c = length(comb(1,:));
    s = size(rgb);
    I = rgb2gray(rgb);
    red = cell(c,1);
    green = cell(c,1);
    blue = cell(c,1);
    for i = 1:s(1)
        for j = 1:s(2)
            idx = dsearchn(comb',[pints(i,j,2) pints(i,j,3)]);
            red{idx,1} = [red{idx,1} rgb(i,j,1)];
            green{idx,1} = [green{idx,1} rgb(i,j,2)];
            blue{idx,1} = [blue{idx,1} rgb(i,j,3)];
        end
    end
    rmeans = zeros(c,1);
    gmeans = zeros(c,1);
    bmeans = zeros(c,1);
    for i = 1:c
        rmeans(i,1) = mean(double(red{i,1}));
        gmeans(i,1) = mean(double(green{i,1}));
        bmeans(i,1) = mean(double(blue{i,1}));
    end
    St = stdfilt(rgb);
    St = St.*St;
    %Calculating Sw
    redResult = zeros(size(rgb(:,:,1)));
    greenResult = zeros(size(rgb(:,:,2)));
    blueResult = zeros(size(rgb(:,:,3)));
    for i = 2:s(1)-1
        for j = 2:s(2)-1 %for every pixel
            rpix = 0; gpix = 0; bpix = 0;
            for a = i-1:i+1
                for b = j-1:j+1
                    rpix = rpix + power((double(rgb(a,b,1)) - rmeans(dsearchn(comb',[pints(a,b,2) pints(a,b,3)]),1)),2);
                    gpix = gpix + power((double(rgb(a,b,2)) - rmeans(dsearchn(comb',[pints(a,b,2) pints(a,b,3)]),1)),2);
                    bpix = bpix + power((double(rgb(a,b,3)) - rmeans(dsearchn(comb',[pints(a,b,2) pints(a,b,3)]),1)),2);
                end
            end
            redResult(i,j) = rpix;
            greenResult(i,j) = gpix;
            blueResult(i,j) = bpix;
        end
    end
    Sw = zeros(size(rgb),'like',rgb);
    Sw(:,:,1) = redResult;
    Sw(:,:,2) = greenResult;
    Sw(:,:,3) = blueResult;
    J = (St-double(Sw))./double(Sw);
    imshow(J);