classdef abstractContProcedureProblem
    % Class that 
    properties (SetAccess=protected,GetAccess=public)
        lastSolution
        lastIterSuccess
        lastMessage=[];
        % fixedParams
        
    end
    properties (SetAccess=protected,GetAccess=private)
        lastSolAvailable=false;
    end
    methods 
        % Solve a problem for a given initial solution and parameters
        % values and manage the continuation procedure fields
        % (lastSolution, lastIterSuccess, lastMessage)
        obj=solveProblemContProcedure(obj,sol,params,fixedParams) % Returns an updated object
        sol=solveProblem(obj,sol,params,fixedParams) % Only returns the solution
    end

    methods
        function obj=abstractContProcedureProblem(options)
            % arguments
            %     % options.fixedParams struct = struct([])
            %    % options.doNotCheckParameterIsAFunction (1,1) logical = false;
            % end
            % obj.fixedParams=options.fixedParams;
         end
        
        %  function checkProblem(obj,sol)
        %     checkFields(obj,paramExemple,obj.fixedParams,);
        %     if ~options.doNotCheckParameterIsAFunction
        %         checkParametersAreNotAlsoFunctions(obj,{paramExemple,options.fixedParams});
        %     end
        % end
        function lastSol=get.lastSolution(obj)
            if obj.lastSolAvailable
                lastSol=obj.lastSolution;
            else
                error('abstractContProcedureProblem: you cannot get a solution before calling solveProblem');
            end
        end
      function lastIterSuccess=get.lastIterSuccess(obj)
            if obj.lastSolAvailable
                lastIterSuccess=obj.lastIterSuccess;
            else
                error('abstractContProcedureProblem: you cannot get iterSuccess status before calling solveProblem');
            end
      end
      function lastMessage=get.lastMessage(obj)
            if obj.lastSolAvailable
                lastMessage=obj.lastMessage;
            else
                error('abstractContProcedureProblem: you cannot get lastMessage before calling solveProblem');
            end
      end

      % Other methods
      obj=reset(obj)
    end
end
