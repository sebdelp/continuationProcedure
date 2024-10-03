function res=H1(z,l)
% Function of the form H(z,l)=0
% Formal solution : z=[cos(l);sin(l)]
res=[z-cos(l);
     z-sin(l)];
end