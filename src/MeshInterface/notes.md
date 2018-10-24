Objects:

Counts: number of different mesh entities, node on them
  - add type parameters, to make this the only object needed to create other objects


local_data: dxidx, nrm, jac, boundaries, interface

remote_data: local_boundaries, remote_boundaries, shared_interfaces, shared_element_offsets, local_elements

Constructors:

 * file names: mesh and geometry
 * volume and face operator (or proxies thereof
 * topology information for reference element
 * bc information (geometry based)

Submesh constructor


Where does sparsity information live?  Who computes it?  It lives at the intersection of the mesh (topology) and discretization (stencil)

## ColoringData Interface

Have a function to get coloring object from mesh, objects should be internally
caches.

Need to define contents of Coloring object: perturbation masks, information to 
figure out where the perturbation came from

 * define concrete type in this package?

## Derivative interface

  Forward and reverse mode

## r-adaptation

  set_coords and commit_coords

## h-adaptation




