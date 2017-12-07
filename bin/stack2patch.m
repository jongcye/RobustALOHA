function out=stack2patch(inp,d)

out=zeros(size(inp,1)*d,size(inp,2)*d);

count=0;
for yiter=1:d
    for xiter=1:d
        count=count+1;
%         out(:,:,count)=inp(yiter:d:end,xiter:d:end);
        out(yiter:d:end,xiter:d:end)=inp(:,:,count);
    end
end