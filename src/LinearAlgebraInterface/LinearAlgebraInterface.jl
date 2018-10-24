"""
Things this needs to abstract:

  abstract type LinearSolver

Preconditioning:
  abstract type AbstractPC
  abstract type AbstractPetscMatPC
  abstract type AbstractPetscMatFreePC
  union of those two

Linear operators:
  abstract type AbstractLO
  abstract type AbstractDenseLO
  abstract type AbstractSparseDirectLO
  abstract type AbstractPetscMatLO
  abstract type AbstractPetscMatFreeLO
  union of those two

functions:
  calcLinearOperator  - calculate Jacobian, or if matfree, calc some stuff
  applyLinearOperator  - does Ax=b
  applyLinearOperatorTranspose  - does A'x = b
  needParallelData
  free
  
Todo:
  which implements the others (type -> function)
  signatures for functions



"""
