module NonlinearSolverInterface

abstract type AbstNonlinearSolver{Tvec} end

"""
A concrete type for nonlinear solver should at least include the following members:
  residual! -> function residual!(res::Tvec, u::Tvec)
  jacobian! -> function jacobian!(jac::SparseMatrix, u::Tvec)
  linsolver -> type of AbstLinearSolver
  precond   -> a preconditioner object of type AbstPreconditioner
  debug     -> a function used only for debugging, which should be left undefined
               in a productive version
  
  These memebers are set using the following functions
"""
function setResidual!(solver::AbstNonlinearSolver{Tvec},
                      residual!::AbstFunction{Tvec}) where Tvec
  solver.residual! = residual!
end

function setLinearSolver!(solver::AbstNonlinearSolver{Tvec},
                          linsolver::AbstLinearSolver{Tvec})
  solver.linsolver = linsolver
end

function setJacobian!(solver::AbstNonlinearSolver{Tvec},
                      jacobian!::AbstLinearOperator{Tvec})
  solver.jacobian = jacobian!
end

function setPreconditioner!(precond::AbstLinearOperator{Tvec},
                            solver::AbstNonlinearSolver{Tvec})
  solver.precond = precond
end

struct InexactNewton{Tvec} <: AbstNonlinearSolver{Tvec}
  res::Tvec
  dx::Tvec
  outprint::Function  # for information output
  histprint::Function # for convergence history plotting
  debug::Function     # for debugging 
  vecnorm::Function   # to define non-standard norms
  state::Dict         # data at each iteration   Anthony wants this changed to a different name
  residual!::AbstFunction{Tvec} # to evaluate the residual
  linsolver::AbstLinearSolver{Tvec} # to solve linear system
  jacobian::AbstLinearOperator{Tvec}
  precond::AbstLinearOperator{Tvec}
  
  function InexactNewton{Tvec}(;outprint::Function=(AbstractString)->nothing,
                               histprint::Function=(AbstractString)->nothing,
                               vecnorm::Function=norm) where Tvec
    solver = new()
    solver.res = Tvec()
    solver.dx  = Tvec()
    solver.outprint = outprint
    solver.histprint = histprint
    solver.debug = debug
    solver.vecnorm = vecnorm
    solver.state = Dict()

    return solver
  end
end

"""
Update the jacobian matrix and preconditioner.

Input/Output:
jac :: jacobian matrix
prec:: preconditioner

Input:
x :: at which value \p jac and \p prec are evaluated
freeze_jac :: don't update jac
freeze_prec:: don't update preconditioner
"""
function updateJacAndPrec!(jac::AbstMatrix{Tvec}, 
                           precond::AbstPreconditioner{Tve}, 
                           x::Tvec;
                           freeze_jac::Bool=false,
                           freeze_prec::Bool=false)
end


function solve!(x::Tvec, solver::InexactNewton{Tvec}, options::Dict)
  # clear state dictionary
  empty!(solver.state)

  # write some data to file
  solver.outprint(repeat('=',80))
  solver.outprint("Nonlinear solve method: Inexact Newton")
  solver.histprint("# " * rpad("iter",5) * rpad("norm",10) * rpad("rel. norm",10))

  # initial residual and update, then begin Newton iterations
  fill!(solver.res, 0.0) # need to define fill!() for our parallel vectors
  fill!(solver.dx, 0.0)  # neither of these fill! statements may be needed

  for k = 1:get!(options, "max_iter", 10)
    solver.state["iter"] = k

    # might want some generic timing calls around the iteration and parts of it;
    # this could also be accomplished with a member function like vecnorm or
    # histprint.

    debug(sovler, res, x)

    # get the residual and its norm
    # Probably will have to use a try catch statement here
    if solver.residual!(solver.res, x) == false
      solver.outprint("failure: residual! invalid at solution")
      return false
    end
    resnorm = norm(solver, solver.res)
    # if we store the whole history in state, we can avoid storing resnorm0
    solver.state["resnorm"] = resnorm # do we forego the variable resnorm for state?
    if k == 1
      resnorm0 = resnorm
      state["resnorm0"] = resnorm0
    end

    # check for convergence
    # This should be an optional function
    if resnorm < options["abs_tol"]
      solver.outprint("success: absolute tolerance satisfied")
      return true
    elseif resnorm < resnorm0*options["rel_tol"]
      solver.outprint("success: relative tolerance satisfied")
      return true
    end

    # Update the matrices, if necessary
    # This is where "policy" decision can be made.  Where should updateMatrices! be defined?
    solver.updateMatrices!(solver.jacobian, solver.precond, x, solver.state)

    # solve for the Newton update; this will call a linear solver that is
    # similar in spirit to this nonlinear solver.
    solve!(solver.dx, solver.linsolver, solver.res, solver.jacobian,
           solver.precond, options["linsolver_options"])

    # update the solution; would need a line search here in general
    axpy!(1.0, solver.dx, x) # this function needs to be generalized for parallel vectors
  end
  # if we get here, then we failed to converge in max_iter iterations
  solver.outprint("Inexact Newton failed to converge in "*
                  string(options["max_iter"])*" iterations")
  return false
end

function debug(solver, x, res, state)
  # if mpi_rank == 3 
  # open your file, using state["iter"] to help name it
  # convert x to q format

end

end # of module NonlinearSolverInterface


