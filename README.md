# Continuation Procedure Toolbox 
# Introduction 

This toolbox is designed to solve a problem of the form $P(x,\phi)$ where $x$ is the unknown and $\phi$ the parameters vector using a Continuation Procedure. 
The problem $P$ can be anything but this toolbox is oriented toward the computation of numerical solution tp Boundary Value Problems (BVP). 
It is assumed that the problem is easy to solve for some known values of $\phi_0$ and difficult to sovle for the value of interest $\phi_1$.

Solving the numerical problem $P$ requires an initial solution in the neighbourhood of the unknown problem solution. As the solution for $\phi=\phi_1$ is totaly unknown the problem cannot be solved directly.

The Continuation Procedure consists in solving the problem starting from a known initial solution $x=x_{ini}$ computed for $\phi=\phi_0$. Then the problem is solved for different $\phi$ values gradually changing from $\phi_0$ to $\phi_1$. 

The continuation procedure toolboxes automatically manages the generation of the successives $\phi$ values and all the provide an easy way to generate the underlying required code (e.g. anonymous functions for the BVP solver). 
It also offers different schedulers to automatically vary the $\phi$ values and automatically using an automatic step size adaptation.

#How to install
The best way to install this toolbox is to use the get add-on menu. Search for "continuationProcedure". The installation is fully automatic.

#How to use
The toolbox provides several examples to implement the continuation procedure. It requires the following steps:
+ Define parameters values
  ```
  paramStart.val1=1;
  paramStart.val2=-50;
  paramEnd.val1=1;
  paramEnd.val2=-50;
  
  ```
+ Define a scheduler object
