#tentativi di vettorizzazione

function vlarCuboidsFacets0(n,dim,V,facets)
	function plarCuboidsFacets1(cell)
		Vert=hcat([V[:,i] for i in cell]...)
        coords = vcat(Vert,reshape(cell,(1,size(cell)[1])))
        doubleFacets=hcat([coords[:,sortperm(coords[k,:])] for k in range(1,dim)]...)
        lastRow=doubleFacets[dim+1,:]
        facets0 = reshape(lastRow,(n,Int(size(lastRow)[1]/n)))
        append!(facets,collect([facets0[:,i] for i in range(1,size(facets0)[2])]))
		return(facets)
	end
	return plarCuboidsFacets1
end

function larCuboidsFacets(V,cells)
    dim = size(V,1)
    n = 2^(dim-1)
    facets = []
    for cell in cells
        Vert=hcat([V[:,i] for i in cell]...)
        coords = vcat(Vert,reshape(cell,(1,size(cell)[1])))
        doubleFacets=hcat([coords[:,sortperm(coords[k,:])] for k in range(1,dim)]...)
        lastRow=doubleFacets[dim+1,:]
        facets0 = reshape(lastRow,(n,Int(size(lastRow)[1]/n)))
        append!(facets,collect([facets0[:,i] for i in range(1,size(facets0)[2])]))
    end
    facets = unique(facets)
    return V,sort(facets, by = x -> x[1])
end

function vlarCuboidsFacets(V,cells)
	dim = size(V,1)
    n = 2^(dim-1)
    facets = []
    W=vlarCuboidsFacets0(n,dim,V,facets).(cells)
	WW=union( W[i] for i in range(1,length(W)))
	facets = unique(WW)
	return V,sort(facets, by = x -> x[1])
end

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
	convertIt = index2addr([ (length(cellLists[k][1]) > 1)? shape+1 : shape  for (k,shape) in enumerate(shapes) ])
	[vcat(convertIt.(jointCells[j])...) for j in 1:size(jointCells,1)]
end

function vbinaryRange(n)
   return bin.(range(0,2^n),n) 
end

function larImageVerts(shape)
   vertLists = vertexDomain.(shape+1) 
   vertGrid = larVertProd(vertLists)
   return vertGrid
end

function larCuboids(shape, full=false)
   vertGrid = larImageVerts(shape)
   gridMap = larGridSkeleton(shape)
   if ! full
      cells = gridMap(length(shape))
   else
      skeletonIds = 0:length(shape)
      cells = gridMap.(skeletonIds)
   end
   return vertGrid, cells
end

function vgridSkeletons(shape)
    gridMap = larGridSkeleton(shape)
    skeletonIds = range(0,length(shape)+1)
    skeletons = gridMap.(skeletonIds)
    return skeletons
end