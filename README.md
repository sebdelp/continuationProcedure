# Continuation Procedure Toolbox 
# Installation & update
## Instalation
The prefered method consists in using Matlab Addon Explorer available from the Add-Ons/Get Add-Ons menu.
Search for "continuation procedure". Select the toolbox and click on the "Add" button.
![Matlab Addon Explorer](images\addonExplorer.png)

Alternatively, the toolbox file "ContinuationProcedure.mltbx" can be downloaded. The from Matlab, double click on this file to install the toolbox.

## Update
Updates are pushed by Mathworks servers. When an update is available, the "bell" icon will becomes red. 
It is located next to your username in the upper right corner of Matlab main menu.
![update](images\update.png)

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
The toolbox provides several examples to implement the continuation procedure.
It requires the following steps:
+ Define parameters values starting & final values
  ```
  paramStart.val1=1;
  paramStart.val2=-50;
  paramEnd.val1=1;
  paramEnd.val2=-50;  
  ```

+ Define a scheduler object
    ```
    scheduler=linScheduler(paramStart,paramEnd);
    ```
+ Define the BVP functions
To solve a BVP problem, the user simply needs to write 2 functions for his problem. These functions can depend on some or all of the parameters defined in paramStart
The first function is the BVP Dynamics:
    ```
    function dydt=f(t,y,val1,val2)
        dydt=....;
    end
    ```
The second one is the boundary condition
    ```
    function res=bc(ya,yb,val1,val2)
        res=...;
    end
    ```
Finally, we write the function that allows interfacing the user defined function with the continuation procedure toolbox:
    ```
    function fode=generateFodeFcn(continuationParams,fixedParams)
        retrieveContinuationParameters({continuationParams,fixedParams});
        % Build a handle to the BVP dynamics
        fode=@(t,y) f(t,y,val1,val2);
    end

    function bcond=generateBCFcn(continuationParams,fixedParams)
        retrieveContinuationParameters({continuationParams,fixedParams});
        % Build a handle to the boundary condition function
        bcond=@(ya,yb) bc(ya,yb,val1,val2);
    end
    ```
+ Define a bvp4or5c problem
    ```
        problem=bvp4or5c("bvp5c",@generateFodeFcn,@generateBCFcn);
    ```

+ Define and execute the continuation procedure
    ```
        cont=continuationProcedure(problem,scheduler,solInit);
        cont.run;
        sol=cont.sol;
    ```
