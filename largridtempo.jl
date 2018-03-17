using IterTools
using DataStructures
using Combinatorics

function larSplit(dom)
    tic()
    function larSplit1(n)
        item = dom/n
        ints = range(0,n+1) 
        vertices=[ints*item;]
        return reshape(vertices,1,n+1)
    end
    toc()
    return larSplit1
end
        
        
function grid_0(n)
    return hcat([[i] for i in range(0,n+1)]...)
end

function grid_1(n)
    return hcat([[i,i+1] for i in range(0,n)]...)
end

function larGrid(n)
    tic()
    function larGrid1(d)
        if d==0 
            return grid_0(n)
        elseif d==1 
            return grid_1(n) 
        end
    end
    toc()
    return larGrid1
end

function larCuboidsFacets(V,cells)
    tic()
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
    toc()
    return V,sort(facets, by = x -> x[1])
end

function larSimplexFacets(simplices)
    tic()
	out = Array{Int32,1}[]
		d = length(simplices[1])
		for simplex in simplices
			append!(out,collect(combinations(simplex,d-1)))
		end
    toc()
	return sort!(unique(out), lt=lexless)
end

function larSimplicialStack(simplices)
    tic()
    dim=size(simplices[1],1)-1   
    faceStack = [simplices]
    for k in range(1,dim)
        faces = larSimplexFacets(faceStack[end])# errore nella chiamata ma p.funzione funziona
        append!(faceStack,[faces])
    end
    toc()
    return flipdim(faceStack,1)
end       

# Cartesian product of collections in its unary argument
function cart(args)
   return sort(collect(IterTools.product(args...)))
end

function larVertProd(vertLists)
   coords = [[x[1] for x in v] for v in cart(vertLists)]
   return sortcols(hcat(coords...))
end

function index2addr(shape::Array{Int32,1})
   index2addr(hcat(shape...))
end

function index2addr(shape::Array{Int32,2})
    n = length(shape)
    theShape = append!(shape[2:end],1)
    weights = [prod(theShape[k:end]) for k in range(1,n)]
    function index2addr0(multiIndex)
        return dot(collect(multiIndex), weights) + 1
    end
    return index2addr0
end

function larCellProd(cellLists)
   shapes = [length(item) for item in cellLists]
   subscripts = cart([collect(range(0,shape)) for shape in shapes])
   indices = hcat([collect(tuple) for tuple in subscripts]...)
   jointCells = Any[]
    tic()
   for h in 1:size(indices,2)
      index = indices[:,h]
      cell = hcat(cart([cells[k+1] for (k,cells) in zip(index,cellLists)])...)
      append!(jointCells,[cell])
   end
    toc()
   convertIt = index2addr([ (length(cellLists[k][1]) > 1)? shape+1 : shape 
      for (k,shape) in enumerate(shapes) ])     
   [vcat(map(convertIt, jointCells[j])...) for j in 1:size(jointCells,1)]
end

function binaryRange(n)
   return [bin(k,n) for k in 0:2^n-1]
end

function filterByOrder(n)
   terms = [[parse(Int8,bit) for bit in convert(Array{Char,1},term)] for term in binaryRange(n)]
   return [[term for term in terms if sum(term) == k] for k in 0:n]
end

function larGridSkeleton(shape)
    tic()
    n = length(shape)
    function larGridSkeleton0(d)
        components = filterByOrder(n)[d+1]
        mymap(arr) = [arr[:,k]  for k in 1:size(arr,2)]
        componentCellLists = [ [ mymap(f(x)) for (f,x) in zip( [larGrid(dim) 
         for dim in shape],component ) ]
               for component in components ]
        out = [ larCellProd(cellLists)  for cellLists in componentCellLists ]
        return vcat(out...)
    end
    toc()
    return larGridSkeleton0
end

function vertexDomain(n)
   return hcat([k for k in 0:n-1]...)
end

function larImageVerts(shape)
   vertLists = [vertexDomain(k+1) for k in shape]
   vertGrid = larVertProd(vertLists)
   return vertGrid
end

function larCuboids(shape, full=false)
    tic()
   vertGrid = larImageVerts(shape)
   gridMap = larGridSkeleton(shape)
   if ! full
      cells = gridMap(length(shape))
   else
      skeletonIds = 0:length(shape)
      cells = [ gridMap(id) for id in skeletonIds ]
   end
    toc()
   return vertGrid, cells
end

function larModelProduct( modelOne, modelTwo )
    tic()
    (V, cells1) = modelOne
    (W, cells2) = modelTwo

    vertices = DataStructures.OrderedDict(); 
    k = 1
    for j in 1:size(V,2)
       v = V[:,j]
        for i in 1:size(W,2)
          w = W[:,i]
            id = [v;w]
            if haskey(vertices, id) == false
                vertices[id] = k
                k = k + 1
            end
        end
    end
    
    cells = []
    for c1 in cells1
        for c2 in cells2
            cell = []
            for vc in c1
                for wc in c2 
                    push!(cell, vertices[[V[:,vc];W[:,wc]]] )
                end
            end
            push!(cells, cell)
        end
    end
    
    vertexmodel = []
    for v in keys(vertices)
        push!(vertexmodel, v)
    end
    verts = hcat(vertexmodel...)
    cells = [[v for v in cell] for cell in cells]
    toc()
    return (verts, cells)
end

function larModelProduct(twoModels)
    modelOne, modelTwo = twoModels
    larModelProduct(modelOne, modelTwo)
end

function gridSkeletons(shape)
    tic()
    gridMap = larGridSkeleton(shape)
    skeletonIds = range(0,length(shape)+1)
    skeletons = [gridMap(id) for id in skeletonIds]
    toc()
    return skeletons
end