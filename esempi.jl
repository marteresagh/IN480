include("largrid.jl")
include("VIEW_FUNC.jl")

#view di un quadrato e di un cubo costruito tramite il prodotto cartesiano
mod_1 = larSplit(1)(1), Cell(1)(1)
square = larModelProduct(mod_1,mod_1)
cube = larModelProduct(square,mod_1)
VIEW(square)
VIEW(cube)

#view di celle esplose
mod_2 = larSplit(3)(2), Cell(2)(1)
squares = larModelProduct(mod_2,mod_2)
VIEW_EXPLODE(squares)
cubes = larModelProduct(squares,mod_2)
VIEW_EXPLODE(cubes)

#estrazione delle facce
CUBE=larCuboids([1,1,1])
FACES=larCuboidsFacets(CUBE[1],CUBE[2])
mod_3=CUBE[1],FACES[2]
VIEW_EXPLODE(mod_3)
simpli=larSimplicialStack(FACES[2])[2]
mod_4=CUBE[1],simpli
VIEW_EXPLODE(mod_4)

#estrazione degli spigoli	
EDGE=larGridSkeleton([1,1,1])(1)
mod_5=CUBE[1],EDGE
VIEW_EXPLODE(mod_5)

#visualizzazione dei 0-,1-,2-,3-scheletro

#0-scheletro
point=CUBE[1],gridSkeletons([1,1,1])[1]
VIEW_EXPLODE(point)

#1-scheletro
edge=CUBE[1],gridSkeletons([1,1,1])[2]
VIEW_EXPLODE(edge)

#2-scheletro
face=CUBE[1],gridSkeletons([1,1,1])[3]
VIEW_EXPLODE(face)

#3-scheletro
cell=CUBE[1],gridSkeletons([1,1,1])[4]
VIEW_EXPLODE(cell)

#numerazione elementi
edge1=CUBE[1],gridSkeletons([1,1,1])
VIEW_NUMBERED(edge1)



!!!!!!aggiungi test che larGridSkeletons e gridSkeleton devono avere degli output comuni