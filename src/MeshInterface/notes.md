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

## Metric Data

  Have separate type to store metric info

  Have setter/getter function for it


## Parallel Data

  TODO: get rid of local boundaries, remote boundaries, create a function
  to get either the left or right boundary from the interface

  need info about peer parts, number of faces/element on peer parts

  I think this is currently general enough for parallel_data == face or element
  Needs to contain counts of parallel faces, who their owners are, etc.

  Also metric info?  Or should metric info be separate from structural info 

## ColoringData Interface

Have a function to get coloring object from mesh, objects should be internally
caches.

Need to define contents of Coloring object: perturbation masks, information to 
figure out where the perturbation came from

 * define concrete type in this package?

## Derivative interface

  Forward and reverse mode

  zero_bar_arrays

  getAllCoordinatesAndMetrics, recalcCoordinatesAndMetrics

  dxidx, jac, coords bar -> vert_coords_bar
  nrm_face, nrm_bndry, face_coords, bndry_coords bar -> vert_coords_bar

  this is partially covered by vertToVolumeCoords_rev, getCurvilinearCoordinatesAndMetrics_rev, getFaceCoordinatesAndNormals_rev

  Need a single function to do it all (to be called after the solver back
  propigates from the residual to the metrics


  add explicit matrix-vector product function for forward mode (even though
  it currenlty uses complex step internally

  Maybe don't back propigate face coordinates (because in ordinary operation
  they never should be used)

## r-adaptation (includes geometry updates/surface adaptation)

  set_coords and commit_coords

  * need to define sematics: does mesh.vert_coords get updated immediately?

  getBoundaries, numberSurfacePoints, coords1DTo3D, coords3DTo1D

  numberSurfacePoints leaks the apf::MeshEntity to the outside world, but
  I don't see another way of doing this.  Perhaps other implementations
  could just return an array of integers/cast back and forth?

  To be fully general, should define an AbstractMeshEntity type.  Perhaps
  have a function for getting this type from the mesh?  Not sure if Julia
  allows

  struct Foo{T}
    a::Vector{getEntityType{T}}
  end

  No, no it doesn't


## h-adaptation

  * getElementSizes
  * adaptMesh


## Iteration

  * Face nodes
  * Faces (all nodes)
  * Volume nodes
  * Volumes (all nodes) == Elements

## Structure Checker

Have a checker function that verifies all required fields are present and
have the right size and have been defined 


## Registration Mechanism

  Need some kind of generic constructor?  a la. flux functions?


## Visualization 

  saveSolutionToMesh, writeVisFiles

  allow saving arbitrary fields?
