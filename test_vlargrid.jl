#Vectorize

using Base.Test

@testset "Module Tests" begin
	@testset "vBinaryRange Tests" begin
		@test vbinaryRange(1)==["0";"1"]
		@test vbinaryRange(2)==["00","01","10","11"]
		@test vbinaryRange(3)==["000","001","010","011","100","101","110","111"]
	end

	@testset "vLarImageVerts Tests" "$shape" for shape in [[3,2,1],[3,2],[10,10,10]]
		@test size(vlarImageVerts(shape)) == (length(shape),prod(shape + 1))
	end

	@testset "VFilterByOrder Tests" begin
		@testset  "$n" for n in 1:4
			data = [vfilterByOrder(n)[k] for (k,el) in enumerate(vfilterByOrder(n))]
			@test sum(map(length,data)) == 2^n
		end

		@testset "$n,$k" for n in 1:4, k in 0:n
			@test length(vfilterByOrder(n)[k+1]) == binomial(n,k)
		end 
	end

	@testset "vlarGridSkeleton Tests" begin
		@test length(vlarGridSkeleton([1,1,1])(0)) == 8
		@test length(vlarGridSkeleton([1,1,1])(1)) == 12
		@test length(vlarGridSkeleton([1,1,1])(2)) == 6
		@test length(vlarGridSkeleton([1,1,1])(3)) == 1
	end

	@testset "vlarCuboidsFacets Tests" begin
		@test length(vlarCuboidsFacets([[0,0] [0,1] [1,1] [1,0]], [[1,2,3,4]])[2]) == 4
		@test size(vlarCuboidsFacets([[0,0] [0,1] [1,1] [1,0]], [[1,2,3,4]])[1],2) == 4 
		@test size(vlarCuboidsFacets([[0,0,0] [0,1,0] [1,1,0] [1,0,0] [0,0,1] [0,1,1] [1,1,1] [1,0,1]], [[1,2,3,4,5,6,7,8]])[1],2) == 8    
		@test length(vlarCuboidsFacets([[0,0,0] [0,1,0] [1,1,0] [1,0,0] [0,0,1] [0,1,1] [1,1,1] [1,0,1]], [[1,2,3,4,5,6,7,8]])[2]) == 6    
	end
	
	@testset "vgridSkeletons Tests" begin
        @test length(vgridSkeletons([3])[1]) == 4
      	@testset "$shape" for shape in [[1,1,1],[3],[2,3]]
			@test length(vgridSkeletons(shape)) == length(shape)+1
			@test typeof(vgridSkeletons(shape)) == Array{Array{Array{Int32,1},1},1}
		end
		@testset "confronto" begin
			@testset "$shape" for shape in [[1,1,1],[2,3],[4]]
			@testset "$d" for d in 0:length(shape)
				@test vlarGridSkeleton(shape)(d)== vgridSkeletons(shape)[d+1] 
				@test typeof(vlarGridSkeleton(shape)(d)) == Array{Array{Int32,1},1}
			end
			end
		end
	end
end
