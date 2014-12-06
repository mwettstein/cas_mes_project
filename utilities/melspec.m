function [ out_data ] = melspec( in_data, P )
out_data = zeros(P);
for i=1:P
    for j=1:length(in_data(:))
        out_data(i) = out_data(i) + sqrt(2/P) * sum(in_data(j)* cos((pi*i/P)*(j-0.5)));
    end
end