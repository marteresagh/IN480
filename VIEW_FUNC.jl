using PyCall
@pyimport larlib as p

function array2list(cells) 
	return PyObject([Any[cell[h] for h=1:length(cell)] for cell in cells])
end

function doublefirst(cells)
	return p.AL([cells[1],cells])
end


function lar2hpc(V::Array{Any,1},CV::Array{Any,1})
		V = hcat(V[1],V...)
		W = [Any[V[h,k] for h=1:size(V,1)] for k=1:size(V,2)]
		hpc = p.STRUCT(p.MKPOLS(PyObject([W,CV,[]])))
	end

function lar2hpc(V::Array{Float64,2},CV::Array{Array{Int,1},1})
		V = hcat(V[:,1],[V[:,k] for k in 1:size(V,2)]...)
		W = [Any[V[h,k] for h=1:size(V,1)] for k=1:size(V,2)]
		hpc = p.STRUCT(p.MKPOLS(PyObject([W,CV,[]])))
end
	
function lar2hpc(V::Array{Int32,2},CV::Array{Array{Int,1},1})
		V = hcat(V[:,1],[V[:,k] for k in 1:size(V,2)]...)
		W = [Any[V[h,k] for h=1:size(V,1)] for k=1:size(V,2)]
		hpc = p.STRUCT(p.MKPOLS(PyObject([W,CV,[]])))
end

function VIEW(mod)
		V,CV= mod
		p.VIEW(lar2hpc(V,CV))
end

function lar2exploded_hpc(V::Array{Any,1},CV::Array{Any,1})
		V = hcat(V[1],V...)
		W = [Any[V[h,k] for h=1:size(V,1)] for k=1:size(V,2)]
		sx,sy,sz = 1.2,1.2,1.2
		hpc = p.EXPLODE(sx,sy,sz)(p.MKPOLS(PyObject([W,CV,[]])))
		
end

	
function lar2exploded_hpc(V::Array{Any,2},CV::Array{Any,2})
		Z = hcat(V[:,1],V)
		W = [Any[Z[h,k] for h=1:size(Z,1)] for k=1:size(Z,2)]
		CV = hcat(CV'...)
		CW = [Any[CV[h,k] for h=1:size(CV,1)] for k=1:size(CV,2)]
		sx,sy,sz = 1.2,1.2,1.2
		hpc = p.EXPLODE(sx,sy,sz)(p.MKPOLS(PyObject([W,CV,[]])))
		hpc = hpc
end

	
function lar2exploded_hpc(V::Array{Int32,2},CV::Array{Array{Int32,1},1})
		Z = hcat(V[:,1],V)
		W = [Any[Z[h,k] for h=1:size(Z,1)] for k=1:size(Z,2)]
		CW = [Any[cell[h] for h=1:length(cell)] for cell in CV]
		sx,sy,sz = 1.2,1.2,1.2
		hpc = p.EXPLODE(sx,sy,sz)(p.MKPOLS(PyObject([W,CV,[]])))
end

	
function lar2exploded_hpc(V::Array{Float64,2},CV::Array{Array{Int32,1},1})
		Z = hcat(V[:,1],V)
		W = [Any[Z[h,k] for h=1:size(Z,1)] for k=1:size(Z,2)]
		CW = [Any[cell[h] for h=1:length(cell)] for cell in CV]
		sx,sy,sz = 1.2,1.2,1.2
		hpc = p.EXPLODE(sx,sy,sz)(p.MKPOLS(PyObject([W,CV,[]])))
end
	
function VIEW_EXPLODE(mod)
		V,CV= mod
		p.VIEW(lar2exploded_hpc(V,CV))
end

function lar2numbered_hpc(larmodel,scaling=1.0)
		V,cells = larmodel
		VV,EV,FV,CV = cells

		Z = hcat(V[:,1],V)
		W = PyCall.PyObject([Any[Z[h,k] for h=1:size(Z,1)] for k=1:size(Z,2)])

		VV,EV,FV,CV = map(doublefirst, [VV+1,EV+1,FV+1,CV+1])
		WW,EW,FW,CW = map(array2list,[VV,EV,FV,CV])
		PyCall.PyObject([WW,EW,FW,CW])
		wire = p.MKPOL(PyCall.PyObject([W,EW,[]]))

		VV,EV,FV,CV = VV-1,EV-1,FV-1,CV-1
		WW,EW,FW,CW = map(array2list,[VV,EV,FV,CV])
		hpc = p.larModelNumbering(1,1,1)(W,PyCall.PyObject([WW,EW,FW,CW]),wire,scaling)
end


function VIEW_NUMBERED(larmodel,scaling=1.0) 
	p.VIEW(lar2numbered_hpc(larmodel,scaling))
end
