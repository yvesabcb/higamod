function ne=nearest_naked_edge(f,v,p)
d=inf;
i=1;
while i<=numel(f)/3
    e=[f(i,1) f(i,2)];  %e2=[f(i,1) f(i,3)];e3=[f(i,2) f(i,3)];  
    isnaked=1;  
    j=1;
     while j<=numel(f)/3 & isnaked
        if j~=i & (e(1)==f(j,1) | e(1)==f(j,3) | e(1)==f(j,2)) & (e(2)==f(j,1) | e(2)==f(j,3) | e(2)==f(j,2) )
           
       isnaked=0;
        end
       j=j+1;
     end
     if isnaked==1 & norm(v(e(1),:)-p)<d
         d=norm(v(e(1),:)-p);
         ne=[e i];
     end 
     
     e=[f(i,2) f(i,3)];  %e2=[f(i,1) f(i,3)];e3=[f(i,2) f(i,3)];  
    isnaked=1;  
    j=1;
     while j<=numel(f)/3 & isnaked
        if j~=i & (e(1)==f(j,1) | e(1)==f(j,3) | e(1)==f(j,2)) & (e(2)==f(j,1) | e(2)==f(j,3) | e(2)==f(j,2) )
           
       isnaked=0;
        end
       j=j+1;
     end
     if isnaked==1 & norm(v(e(1),:)-p)<d
         d=norm(v(e(1),:)-p);
         ne=[e i];
     end 
     
     e=[f(i,1) f(i,3)];  %e2=[f(i,1) f(i,3)];e3=[f(i,2) f(i,3)];  
    isnaked=1;  
    j=1;
     while j<=numel(f)/3 & isnaked
        if j~=i & (e(1)==f(j,1) | e(1)==f(j,3) | e(1)==f(j,2)) & (e(2)==f(j,1) | e(2)==f(j,3) | e(2)==f(j,2) )
           
       isnaked=0;
        end
       j=j+1;
     end
     if isnaked==1 & norm(v(e(1),:)-p)<d
         d=norm(v(e(1),:)-p);
         ne=[e i];
     end
     i=i+1;
end
end