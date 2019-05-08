function drawCells(dat, cell_indecies)
% Shows 3d stack image with overlayed cells

cells = dat.stat;
if nargin < 2
    cell_indecies = find([cells.iscell] > 0);
end


%img = dat.mimg;
%if isfield(dat,'roi_img')
%    img = dat.roi_img;
%end
M = rescale(dat.ops.mimg1(dat.ops.yrange, dat.ops.xrange), 0, 1);
%imagesc()
%colormap gray

BW = zeros(size(M));
L = zeros(size(M));


% draw each ROI
for i=1:numel(cell_indecies)
    cell_index = cell_indecies(i);
    x = cells(cell_index).xpix;
    y = cells(cell_index).ypix;
    bw = boundary(x,y);
    
    lambdas = cells(cell_index).lambda;
    for j = 1:numel(x)
        L(y(j),x(j)) = min(0.01 + 5 * lambdas(j), 2);
    end
    
    %for j = 1:numel(bw)
    %    BW(y(bw(j)), x(bw(j))) = 1;
    %end

    idist  = sqrt(bsxfun(@minus, cells(cell_index).xpix', cells(cell_index).xpix).^2 + ...
       bsxfun(@minus, cells(cell_index).ypix', cells(cell_index).ypix).^2);
    idist  = idist - diag(NaN*diag(idist));
    extpix = sum(idist <= sqrt(2)) <= 6;
    xext = cells(cell_index).xpix(extpix);
    yext = cells(cell_index).ypix(extpix);
    for j = 1:numel(xext)
        BW(yext(j), xext(j)) = 0.1;
    end

    
    %plot(x(bw), y(bw), 'r');
    
    %text(max(x), mean(y), ...
    %    num2str(cell_index),...
    %    'Color', 'r');
end


M=rescale(M, 0.11, 0.7);
% Gray movie in RGB
I = cat(3, M, M, M);

% Add lambdas in magenta
I(:,:,1) = I(:,:,1) + L;
I(:,:,3) = I(:,:,3) + L;

% Add outlines in red
I(:,:,1) = I(:,:,1) + BW;
I(:,:,3) = I(:,:,3) + BW;

figure;
imagesc(I);
figure(); imagesc(L); colormap gray;

end

