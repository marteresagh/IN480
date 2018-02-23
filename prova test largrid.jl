using Base.Test

@testset "Module Tests" begin

	@testset "larSplit Tests" begin
           quarto=larSplit(5)(4)[5]-larSplit(5)(4)[4]
           terzo=larSplit(5)(4)[4]-larSplit(5)(4)[3]
           secondo=larSplit(5)(4)[3]-larSplit(5)(4)[2]
           primo=larSplit(5)(4)[2]-larSplit(5)(4)[1]    
               @test primo == 1.25
               @test secondo == 1.25
               @test terzo == 1.25
               @test quarto == 1.25
	end

	@testset "larGrid Tests" begin
		@testset "grid_0" begin
			@test grid_0(1) == [0  1]
			@test grid_0(2) == [0  1  2]
			@test grid_0(3) == [0  1  2  3]
		end
   
		@testset "grid_1 Tests" begin
			@test repr(grid_1(1)) == "[0; 1]"
			@test grid_1(2) == [0 1; 1 2]
			@test grid_1(3) == [0 1 2; 1 2 3]
		end
   
		@testset "larGrid" begin
			@test repr(larGrid(1)(0)) == "[0 1]"
			@test repr(larGrid(1)(1)) == "[0; 1]"
			@test larGrid(2)(0) == [0  1  2]
			@test larGrid(2)(1) == [0 1; 1 2]
			@test larGrid(3)(0) == [0  1  2  3]
			@test larGrid(3)(1) == [0  1  2; 1  2  3]
		end
	end 

	@testset "Cell Tests" begin
		@testset "grid0" begin
			@test grid0(1) == [[1],[2]]
			@test grid0(2) == [[1],[2],[3]]
			@test grid0(3) == [[1],[2],[3],[4]]
		end
   
		@testset "grid1" begin
			@test repr(grid1(1)) == "Array{Int32,1}[[1, 2]]"
			@test grid1(2) == [[1,2], [2,3]]
			@test grid1(3) == [[1, 2], [2, 3],[3, 4]]
		end
   
		@testset "Cell" begin
			@test repr(Cell(1)(0)) == "Array{Int32,1}[[1], [2]]"
			@test repr(Cell(1)(1)) == "Array{Int32,1}[[1, 2]]"
			@test Cell(2)(0) == [[1],[2],[3]]
			@test Cell(2)(1) == [[1,2],[2,3]]
			@test Cell(3)(0) == [[1],[2],[3],[4]]
			@test Cell(3)(1) == [[1,2],[2,3],[3,4]]
		end
	end

	@testset "Index2addr Tests" begin
		@testset "shape 1D" begin
			@test index2addr([10])([0])==1
			@test index2addr([10])([9])==10
			@test [index2addr([10])([index]) for index in collect(0:9)]==collect(1:10)
		end

		@testset "shape 2d" begin
		aa = cart([[0;1;2],[0;1]])
		bb = cart([collect(0:9),collect(0:1)])
		cc = cart([collect(0:2),collect(0:2)])
		dd = "Tuple{Int32,Int32}[(0, 0), (0, 1), (1, 0), (1, 1), (2, 0), (2, 1)]"
			@test [ index2addr([3,2])(index) for index in aa ]==collect(1:6)
			@test [ index2addr([10,2])(index) for index in bb ] == collect(1:20)
			@test [ index2addr([3,3])(index) for index in cc] == collect(1:9)
			@test repr( cart([collect(0:2),collect(0:1)]) )==dd
		end

		@testset "shape 3d" begin
		aaa = cart([collect(0:3),collect(0:2),collect(0:1)])
		bbb = cart([[0;1;2],[0;1],[0;1]])
		ccc = cart([[0;1],[0;1],[0;1;2]])
			@test index2addr([3,2,1])([0,0,0]) == 1
			@test [ index2addr([4,3,2])(index) for index in aaa ] == collect(1:24)
			@test [index2addr([3,2,2])(index) for index in bbb ] == collect(1:12)
			@test [index2addr([2,2,3])(index) for index in ccc ] == collect(1:12)
		end
	end

	@testset "BinaryRange Tests" begin
		@test binaryRange(1)==["0";"1"]
		@test binaryRange(2)==["00","01","10","11"]
		@test binaryRange(3)==["000","001","010","011","100","101","110","111"]
	end

	@testset "LarVertProd Tests" begin
		@testset "LarVertProd 1D" begin
			shape = [3]
			vertLists = [vertexDomain(k+1) for k in shape]
			@test typeof(larVertProd(vertLists))==Array{Int32,2}
			@test size(larVertProd(vertLists))==(1, 4)
			@test larVertProd(vertLists)[:,1]==[0]
			@test larVertProd(vertLists)[:,4]==[3]
		end

		@testset "LarVertProd 2D" begin
			shape = [3,2]
			vertLists = [vertexDomain(k+1) for k in shape]
			@test typeof(larVertProd(vertLists))==Array{Int32,2}
			@test size(larVertProd(vertLists))==(2, 12)
			@test larVertProd(vertLists)[:,1]==[0;0]
			@test larVertProd(vertLists)[:,12]==[3;2]
		end

		@testset "LarVertProd 3D" begin
			shape = [3,2,1]
			vertLists = [vertexDomain(k+1) for k in shape]
			@test typeof(larVertProd(vertLists))==Array{Int32,2}
			@test size(larVertProd(vertLists))==(3, 24)
			@test larVertProd(vertLists)[:,1]==[0;0;0]
			@test larVertProd(vertLists)[:,24]==[3;2;1]
		end
	end

	@testset "FilterByOrder Tests" begin
		term = "000"
		bit = '0'
		theTerm = convert(Array{Char,1},term)
		@test typeof(theTerm) == Array{Char,1}
		@test parse(Int8,bit) == 0
		@test [parse(Int8,bit) for bit in theTerm] == zeros(3)
		out = hcat([[parse(Int8,bit) for bit in term] for term in binaryRange(3)]...)
		@test typeof(out) == Array{Int8,2}
		@test size(out) == (3,8)
		@test repr(out) == "Int8[0 0 0 0 1 1 1 1; 0 0 1 1 0 0 1 1; 0 1 0 1 0 1 0 1]"
	end

	@testset "LarImageVerts Tests" "$shape" for shape in [[3,2,1],[3,2],[10,10,10]]
		@test size(larImageVerts(shape)) == (length(shape),prod(shape + 1))
	end

	@testset "FilterByOrder Tests" begin
		@testset  "$n" for n in 1:4
			data = [filterByOrder(n)[k] for (k,el) in enumerate(filterByOrder(n))]
			@test sum(map(length,data)) == 2^n
		end

		@testset "$n,$k" for n in 1:4, k in 0:n
			@test length(filterByOrder(n)[k+1]) == binomial(n,k)
		end 
	end

	@testset "larGridSkeleton Tests" begin
		@test length(larGridSkeleton([1,1,1])(0)) == 8
		@test length(larGridSkeleton([1,1,1])(1)) == 12
		@test length(larGridSkeleton([1,1,1])(2)) == 6
		@test length(larGridSkeleton([1,1,1])(3)) == 1
	end

	@testset "larSimplicialStack Tests" begin
        @testset "example1" begin
			triang2d=[[1,2,3],[2,3,4],[3,4,5]]
            triang3d=[[1,2,3,4],[2,3,4,5],[2,4,5,6],[4,5,6,7],[3,4,5,7],[3,4,7,9],[3,4,8,9],[1,3,4,8],[1,2,4,6],[1,4,6,8],[4,6,8,9],[4,6,7,9]]
            Vert2d=length(larSimplicialStack(triang2d)[1])
            Seg2d=length(larSimplicialStack(triang2d)[2])
            Fac2d=length(larSimplicialStack(triang2d)[3])
            Vert3d=length(larSimplicialStack(triang3d)[1])
            Seg3d=length(larSimplicialStack(triang3d)[2])
            Fac3d=length(larSimplicialStack(triang3d)[3])
            Cel3d=length(larSimplicialStack(triang3d)[4])
                @test Vert2d-Seg2d+Fac2d == 1
                @test Vert3d-Seg3d+Fac3d-Cel3d == 1
		end
		
		@testset "example2" begin
            triang2d=[[1,2,3],[2,3,4],[3,4,5]]
            triang3d=[[1,2,3,4],[2,3,4,5],[2,4,5,6],[2,4,6,7],[1,2,4,8],[2,4,7,8]]
            Vert2d=length(larSimplicialStack(triang2d)[1])
            Seg2d=length(larSimplicialStack(triang2d)[2])
            Fac2d=length(larSimplicialStack(triang2d)[3])
            Vert3d=length(larSimplicialStack(triang3d)[1])
            Seg3d=length(larSimplicialStack(triang3d)[2])
            Fac3d=length(larSimplicialStack(triang3d)[3])
            Cel3d=length(larSimplicialStack(triang3d)[4])
                @test Vert2d-Seg2d+Fac2d == 1
                @test Vert3d-Seg3d+Fac3d-Cel3d == 1
		end
	end	
	
	@testset "larCuboidsFacets Tests" begin
		@test length(larCuboidsFacets([[0,0] [0,1] [1,1] [1,0]], [[1,2,3,4]])[2]) == 4
		@test size(larCuboidsFacets([[0,0] [0,1] [1,1] [1,0]], [[1,2,3,4]])[1],2) == 4 
		@test size(larCuboidsFacets([[0,0,0] [0,1,0] [1,1,0] [1,0,0] [0,0,1] [0,1,1] [1,1,1] [1,0,1]], [[1,2,3,4,5,6,7,8]])[1],2) == 8    
		@test length(larCuboidsFacets([[0,0,0] [0,1,0] [1,1,0] [1,0,0] [0,0,1] [0,1,1] [1,1,1] [1,0,1]], [[1,2,3,4,5,6,7,8]])[2]) == 6    
	end
	
	@testset "gridSkeletons Tests" begin
        @test length(gridSkeletons([3])[1]) == 4
      	@testset "$shape" for shape in [[1,1,1],[3],[2,3]]
			@test length(gridSkeletons(shape)) == length(shape)+1
			@test typeof(gridSkeletons(shape)) == Array{Array{Array{Int32,1},1},1}
		end
	end

end
