function out=patch2stack(inp,d)

out=zeros(size(inp,1)/d,size(inp,2)/d,d);
count=0;
for yiter=1:d
    for xiter=1:d
        count=count+1;
        out(:,:,count)=inp(yiter:d:end,xiter:d:end);
    end
end