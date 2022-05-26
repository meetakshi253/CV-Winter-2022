function [krf,krl] = kmeans_seg_k(I,k)
I=double(I);
[M,N,ch]=size(I);
Id=reshape(I,M*N,ch,1);
kd=Id(ceil(rand(k,1)*M*N),:);
kdo=kd;
itr=0;
while(1)
    itr=itr+1;
dist=pdist2(Id,kdo);
[~,label]=min(dist,[],2);
for i=1:k
kd(i,:)=mean(Id(label==i,:));
end
err=sum(sum(abs(kd-kdo)));
if err<k||itr>max(5,sqrt(k))
    break;
end
kdo=kd;
end
kd=round(kd);
kr=kd(label,:);
krf=uint8(reshape(kr,M,N,ch));
krl=reshape(label,M,N,1);
end