#Parallel

using Base.Test

@testset "Module Tests" begin

	@testset "plarGrid Tests" begin
		@testset "pgrid_0" begin
			@test pgrid_0(1) == [0  1]
			@test pgrid_0(2) == [0  1  2]
			@test pgrid_0(3) == [0  1  2  3]
		end
   
		@testset "pgrid_1 Tests" begin
			@test repr(pgrid_1(1)) == "[0, 1]"
			@test pgrid_1(2) == [0 1; 1 2]
			@test pgrid_1(3) == [0 1 2; 1 2 3]
		end
   
		@testset "plarGrid" begin
			@test repr(plarGrid(1)(0)) == "[0 1]"
			@test repr(plarGrid(1)(1)) == "[0, 1]"
			@test plarGrid(2)(0) == [0  1  2]
			@test plarGrid(2)(1) == [0 1; 1 2]
			@test plarGrid(3)(0) == [0  1  2  3]
			@test plarGrid(3)(1) == [0  1  2; 1  2  3]
		end
	end 

	@testset "plarGridSkeleton Tests" begin
		@test length(plarGridSkeleton([1,1,1])(0)) == 8
		@test length(plarGridSkeleton([1,1,1])(1)) == 12
		@test length(plarGridSkeleton([1,1,1])(2)) == 6
		@test length(plarGridSkeleton([1,1,1])(3)) == 1
	end

	@testset "plarSimplicialStack Tests" begin
        @testset "example1" begin
			triang2d=[[1,2,3],[2,3,4],[3,4,5]]
            triang3d=[[1,2,3,4],[2,3,4,5],[2,4,5,6],[4,5,6,7],[3,4,5,7],[3,4,7,9],[3,4,8,9],[1,3,4,8],[1,2,4,6],[1,4,6,8],[4,6,8,9],[4,6,7,9]]
            Vert2d=length(plarSimplicialStack(triang2d)[1])
            Seg2d=length(plarSimplicialStack(triang2d)[2])
            Fac2d=length(plarSimplicialStack(triang2d)[3])
            Vert3d=length(plarSimplicialStack(triang3d)[1])
            Seg3d=length(plarSimplicialStack(triang3d)[2])
            Fac3d=length(plarSimplicialStack(triang3d)[3])
            Cel3d=length(plarSimplicialStack(triang3d)[4])
                @test Vert2d-Seg2d+Fac2d == 1
                @test Vert3d-Seg3d+Fac3d-Cel3d == 1
		end
		
		@testset "verifica" begin
			@testset "$shape" for shape in [[1,2,3,4],[2,3,4,5,6]]
				@test length(plarSimplicialStack([shape])) == length(shape)
				@test typeof(plarSimplicialStack([shape])) ==  Array{Array{Array{Int32,1},1},1}
			end
		end
	end	
	
	@testset "plarCuboidsFacets Tests" begin
		@test length(plarCuboidsFacets([[0,0] [0,1] [1,1] [1,0]], [[1,2,3,4]])[2]) == 4
		@test size(plarCuboidsFacets([[0,0] [0,1] [1,1] [1,0]], [[1,2,3,4]])[1],2) == 4 
		@test size(plarCuboidsFacets([[0,0,0] [0,1,0] [1,1,0] [1,0,0] [0,0,1] [0,1,1] [1,1,1] [1,0,1]], [[1,2,3,4,5,6,7,8]])[1],2) == 8    
		@test length(plarCuboidsFacets([[0,0,0] [0,1,0] [1,1,0] [1,0,0] [0,0,1] [0,1,1] [1,1,1] [1,0,1]], [[1,2,3,4,5,6,7,8]])[2]) == 6    
	end
	
	@testset "pgridSkeletons Tests" begin
        @test length(pgridSkeletons([3])[1]) == 4
      	@testset "$shape" for shape in [[1,1,1],[3],[2,3]]
			@test length(pgridSkeletons(shape)) == length(shape)+1
			@test typeof(pgridSkeletons(shape)) == Array{Array{Array{Int32,1},1},1}
		end
		@testset "confronto" begin
			@testset "$shape" for shape in [[1,1,1],[2,3],[4]]
			@testset "$d" for d in 0:length(shape)
				@test plarGridSkeleton(shape)(d)== pgridSkeletons(shape)[d+1] 
				@test typeof(plarGridSkeleton(shape)(d)) == Array{Array{Int32,1},1}
			end
			end
		end
	end
end
