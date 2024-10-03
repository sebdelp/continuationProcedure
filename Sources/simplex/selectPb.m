function [H,n,solFcn]=selectPb(no)

switch no
    case 1
        % Sol z=sin(l)
        H=@H1;
        n=1;
        %  solution
        solFcn=@(l) sin(l);
    case 2
        H=@H2;
        n=2;
         %  solution
        solFcn=@(l) [cos(l); sin(l)];
end