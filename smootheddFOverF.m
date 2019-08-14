function [ dF, Fbase ] = smootheddFOverF(F)
%Delta F over F base computed for a locally adjusted F base.
%   F base is a value of linear regression of the signal -- removes low
%   oscillation changes in the signal

dF = zeros(size(F));
for i = 1:size(F,1)
    Fbase = smooth(F(i,:), 0.1, 'lowess')';
    dF(i,:) = (F(i,:) - Fbase) ./ Fbase;
end

end
