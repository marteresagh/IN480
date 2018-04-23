#= Module Largrid - Parallel Function =#

@everywhere using IterTools
@everywhere using DataStructures
@everywhere using Combinatorics

#-LARCUBOIDSFACETS-
#PMAP
@everywhere function plarCuboidsFacets0(n,dim,V,facets)
	function plarCuboidsFacets1(cell)
		Vert=@parallel (hcat) for i in cell V[:,i] end
		coords = vcat(Vert,reshape(cell,(1,size(cell)[1])))
		doubleFacets=@parallel (hcat) for k in range(1,dim) 
					coords[:,sortperm(coords[k,:])] 
		end
		lastRow=doubleFacets[dim+1,:]
		facets0 = reshape(lastRow,(n,Int(size(lastRow)[1]/n)))
		append!(facets,collect([facets0[:,i] for i in range(1,size(facets0)[2])]))
		return facets
	end
	return plarCuboidsFacets1
end

function plarCuboidsFacets(V,cells)
	dim = size(V,1)
	n = 2^(dim-1)
	facets = []
	W=pmap(plarCuboidsFacets0(n,dim,V,facets),cells)
	WW=@parallel (union) for i in range(1,length(W)) W[i] end
	facets = unique(WW)
	return V,sort(facets, by = x -> x[1])
end

#PARALLEL LOOP
@everywhere function plarCuboidsFacets0(n,dim,V,cell,facets)
	Vert=@parallel (hcat) for i in cell V[:,i] end
	coords = vcat(Vert,reshape(cell,(1,size(cell)[1])))
	doubleFacets=@parallel (hcat) for k in range(1,dim)
			coords[:,sortperm(coords[k,:])] 
	end
	lastRow=doubleFacets[dim+1,:]
	facets0 = reshape(lastRow,(n,Int(size(lastRow)[1]/n)))
	append!(facets,collect([facets0[:,i] for i in range(1,size(facets0)[2])]))
	return facets
end

function plarCuboidsFacets(V,cells)
	dim = size(V,1)
	n = 2^(dim-1)
	facets = []
	W=@parallel (append!) for cell in cells
			fetch( @spawn plarCuboidsFacets0(n,dim,V,cell,facets))
	end
	facets = unique(W)
	return V,sort(facets, by = x -> x[1])
end

#-LARGRID-
#PARALLEL LOOP
@everywhere function pgrid_0(n)
	W=@parallel (hcat) for i in range(0,n+1) 
		[i] 
	end
	return W
end

@everywhere function pgrid_1(n)
	W=@parallel (hcat) for i in range(0,n) 
		[i,i+1] 
	end
	return W
end

@everywhere function plarGrid(n)
    function larGrid1(d)
        if d==0 
            return pgrid_0(n)
        elseif d==1 
            return pgrid_1(n) 
        end
    end
    return larGrid1
end

#-LARSIMPLICIALSTACK-
#PARALLEL LOOP
@everywhere function plarSimplexFacets(simplices::Array{Array{Int32,1},1})
	out =  Array{Int32,1}[]
	d = length(simplices[1])
	out=@parallel (append!) for simplex in simplices
		collect(combinations(simplex,d-1))
	end
	return sort!(unique(out), lt=lexless)
end

function plarSimplicialStack(simplices:: Array{Array{Int32,1},1})
    dim=size(simplices[1],1)-1   
    faceStack = [simplices]
    for k in range(1,dim)
        faces = plarSimplexFacets(faceStack[end])
        append!(faceStack,[faces])
    end
    return flipdim(faceStack,1)
end        

#-LARGRIDSKELETON-

@everywhere function cart(args)
   return sort(collect(IterTools.product(args...)))
end

@everywhere function larVertProd(vertLists)
   coords = [[x[1] for x in v] for v in cart(vertLists)]
   return sortcols(hcat(coords...))
end

@everywhere function index2addr(shape::Array{Int32,1})
   index2addr(hcat(shape...))
end

@everywhere function index2addr(shape::Array{Int32,2})
    n = length(shape)
    theShape = append!(shape[2:end],1)
    weights = [prod(theShape[k:end]) for k in range(1,n)]
    function index2addr0(multiIndex)
        return dot(collect(multiIndex), weights) + 1
    end
    return index2addr0
end

#PARALLEL LOOP
@everywhere function plarCellProd(cellLists)
	shapes = [length(item) for item in cellLists]
	subscripts = cart([collect(range(0,shape)) for shape in shapes])
	indices = hcat([collect(tuple) for tuple in subscripts]...)
	jointCells = Any[]
	jointCells = @parallel (append!) for h in 1:size(indices,2)
		index = indices[:,h]
		cell = [hcat(cart([cells[k+1] for (k,cells) in zip(index,cellLists)])...)]
	end
	convertIt = index2addr([ (length(cellLists[k][1]) > 1)? shape+1 : shape 
		for (k,shape) in enumerate(shapes) ])     
	[vcat(pmap(convertIt, jointCells[j])...) for j in 1:size(jointCells,1)]
end

@everywhere function binaryRange(n)
   return [bin(k,n) for k in 0:2^n-1]
end

@everywhere function filterByOrder(n)
   terms = [[parse(Int8,bit) for bit in convert(Array{Char,1},term)]
		for term in binaryRange(n)]
   return [[term for term in terms if sum(term) == k] for k in 0:n]
end

@everywhere function plarGridSkeleton(shape)
    n = length(shape)
    function larGridSkeleton0(d)
        components = filterByOrder(n)[d+1]
        mymap(arr) = [arr[:,k]  for k in 1:size(arr,2)]
        componentCellLists = [[mymap(f(x)) for (f,x) in zip([plarGrid(dim) 
			for dim in shape], component)] for component in components]
		out = [plarCellProd(cellLists)  for cellLists in componentCellLists]
        return vcat(out...)
    end
    return larGridSkeleton0
end

#PARALLEL LOOP
@everywhere function pvertexDomain(n)
	 a = @parallel (hcat) for k in 0:n-1
			[k]
		end
	return a
end

@everywhere function plarImageVerts(shape)
   vertLists = [pvertexDomain(k+1) for k in shape]
   vertGrid = larVertProd(vertLists)
   return vertGrid
end

@everywhere function plarCuboids(shape, full=false)
   vertGrid = plarImageVerts(shape)
   gridMap = plarGridSkeleton(shape)
   if ! full
      cells = gridMap(length(shape))
   else
      skeletonIds = 0:length(shape)
      cells = [ gridMap(id) for id in skeletonIds ]
   end
   return vertGrid, cells
end

#-GRIDSKELETONS-
function pgridSkeletons(shape)
    gridMap = plarGridSkeleton(shape)
    skeletonIds = range(0,length(shape)+1)
    skeletons = [gridMap(id) for id in skeletonIds]
    return skeletons
end