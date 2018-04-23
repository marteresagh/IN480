#-LARCUBOIDSFACETS-
function vlarCuboidsFacets0(n,dim,V)
	function vlarCuboidsFacets1(cell)
		facets=[]
		Vert=hcat([V[:,i] for i in cell]...)
		coords = vcat(Vert,reshape(cell,(1,size(cell)[1])))
		doubleFacets=hcat([coords[:,sortperm(coords[k,:])] 
					for k in range(1,dim)]...)
		lastRow=doubleFacets[dim+1,:]
		facets0 = reshape(lastRow,(n,Int(size(lastRow)[1]/n)))
		append!(facets,collect([facets0[:,i]
						for i in range(1,size(facets0)[2])]))
		return(facets)
	end
	return vlarCuboidsFacets1
end

function vlarCuboidsFacets(V,cells)
	dim = size(V,1)
	n = 2^(dim-1)
	W=vlarCuboidsFacets0(n,dim,V).(cells)
	WW=union([W[i] for i in range(1,length(W))]...)
	facets = unique(WW)
	return V,sort(facets, by = x -> x[1])
end

#-LARGRIDSKELETON-
function larCellProd0(indices,cellLists)
	function larCellProd1(h)
		index = indices[:,h]
		cell = hcat(cart([cells[k+1] for (k,cells) in zip(index,cellLists)])...)	
		return cell
	end
	return larCellProd1
end
	
function vlarCellProd(cellLists)
	shapes = length.(cellLists)
	subscripts = cart(collect(range.(0,shapes)))
	indices = hcat(collect.(subscripts)...)
	jointCells = larCellProd0(indices,cellLists).( range(1,size(indices,2)))
	convertIt = index2addr([(length(cellLists[k][1]) > 1)? shape+1 : shape 
					for (k,shape) in enumerate(shapes)])
	[vcat(convertIt.(jointCells[j])...) for j in 1:size(jointCells,1)]
end

function vbinaryRange(n)
	return bin.(range(0,2^n),n) 
end

function vlarImageVerts(shape)
	vertLists = vertexDomain.(shape+1) 
	vertGrid = larVertProd(vertLists)
	return vertGrid
end

function vfilterByOrder(n)
	terms = [[parse(Int8,bit) for bit in convert(Array{Char,1},term)] 
							for term in vbinaryRange(n)]
	return [[term for term in terms if sum(term) == k] for k in 0:n]
end

function vlarGridSkeleton(shape)
    n = length(shape)
    function larGridSkeleton0(d)
        components = filterByOrder(n)[d+1]
        mymap(arr) = [arr[:,k] for k in 1:size(arr,2)]
        componentCellLists = [[mymap(f(x)) 
				for (f,x) in zip(larGrid.(shape),component)]
					for component in components]
        out = vlarCellProd.(componentCellLists)
        return vcat(out...)
    end
    return larGridSkeleton0
end

#-LARCUBOIDS-
function vlarCuboids(shape, full=false)
   vertGrid = vlarImageVerts(shape)
   gridMap = vlarGridSkeleton(shape)
   if ! full
      cells = gridMap(length(shape))
   else
      skeletonIds = 0:length(shape)
      cells = gridMap.(skeletonIds)
   end
   return vertGrid, cells
end

#-GRIDSKELETONS-
function vgridSkeletons(shape)
    gridMap = vlarGridSkeleton(shape)
    skeletonIds = range(0,length(shape)+1)
    skeletons = gridMap.(skeletonIds)
    return skeletons
end