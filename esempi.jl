include("largrid.jl")
include("VIEW_FUNC.jl")

#view di un quadrato e di un cubo costruito tramite il prodotto cartesiano
mod_1 = larSplit(1)(1), Cell(1)(1)
square = larModelProduct(mod_1,mod_1)
cube = larModelProduct(square,mod_1)
VIEW(square)
VIEW(cube)

#view di celle esplose
mod_2 = larSplit(3)(3), Cell(3)(1)
squares = larModelProduct(mod_2,mod_2)
VIEW_EXPLODE(squares)
cubes = larModelProduct(squares,mod_2)
#numero dei vertici
vertici=size(cubes[1],2)
#numero dei cubetti
cubi=length(cubes[2])
VIEW_EXPLODE(cubes)

#estrazione delle facce con larCuboidsFacets
CUBE=larCuboids([1,1,1])
V,FACES=larCuboidsFacets(CUBE[1],CUBE[2])
length(FACES)
mod_3=V,FACES
VIEW_EXPLODE(mod_3)

#visualizzazione dei 0-,1-,2-,3-scheletro con larGridSkeleton

#0-scheletro 
point=CUBE[1],larGridSkeleton([1,1,1])(0)
length(point[2])
VIEW(point)

#1-scheletro
edge=CUBE[1],larGridSkeleton([1,1,1])(1)
length(edge[2])
VIEW_EXPLODE(edge)

#2-scheletro
face=CUBE[1],larGridSkeleton([1,1,1])(2)
length(face[2])
VIEW_EXPLODE(face)

#3-scheletro
cell=CUBE[1],larGridSkeleton([1,1,1])(3)
length(cell[2])
VIEW_EXPLODE(cell)

#numerazione elementi di tutti gli scheletri
schel1=CUBE[1],gridSkeletons([1,1,1])
VIEW_NUMBERED(schel1)

#esempio di visualizzazione triangoli e tetraedri
v,ev=[0 1 0; 0 0 1],[[1,2],[2,3],[1,3]]
tri_edge=v,ev
VIEW(tri_edge)

v,fv=[0 1 0; 0 0 1],[[1,2,3]]
triangle=v,fv
VIEW(triangle)

#1-scheletro
vv,evv=[0 1 0 0 ; 0 0 1 0;0 0 0 1],larSimplicialStack([[1,2,3,4]])[2]
tetra_edge=vv,evv
VIEW(tetra_edge)

#2-scheletro
vv,fvv=[0 1 0 0 ; 0 0 1 0;0 0 0 1],larSimplicialStack([[1,2,3,4]])[3]
tetra_face=vv,fvv
VIEW_EXPLODE(tetra_face)

#3-scheletro
vv,cvv=[0 1 0 0 ; 0 0 1 0;0 0 0 1],[[1,2,3,4]]
tetra=vv,cvv
VIEW(tetra)

#numerazione usando larSimplicialStack
simpli=larSimplicialStack(cvv)
schel2=vv,simpli
VIEW_NUMBERED(schel2)