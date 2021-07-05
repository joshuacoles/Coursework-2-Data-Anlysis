### A Pluto.jl notebook ###
# v0.14.3

using Markdown
using InteractiveUtils

# ╔═╡ 86e14002-84f5-434c-959b-0ae8cd0cba0e
begin
	using CSV
	using DataFrames
	using Plots
end

# ╔═╡ 70aae19b-4373-408c-9b8d-678296728e98
using Statistics

# ╔═╡ b7f34dfe-2177-4ffd-a381-b91bf9d4d5d7
using Polynomials

# ╔═╡ 5dd8bd52-41c0-450d-bfac-4965b5a16419
plotlyjs()

# ╔═╡ cbccf93a-1470-438a-95ee-51156fad94b1
begin
	data = CSV.read("./dc-100-100-0-10000.csv", DataFrame; header=[:ts, :nC, :pD, :pF])
	data.pD = data.pD ./ 10
	data.pF = data.pF ./ 50
end

# ╔═╡ 3a37eff8-22ec-4076-904b-f3290b6cde35
scatter(data.nC, data.pD, data.pF)

# ╔═╡ b7f7c210-57d4-4cc9-b7aa-384481e0103a
scatter(data.nC, data.pF)

# ╔═╡ c5bde7f4-4acd-4614-8374-8fceaa3f32f8
scatter(data.pD, data.pF; xlabel = "pSuper", ylabel = "Path %")

# ╔═╡ d3c6b450-5365-4b0e-a4f1-da50edee6bc2
scatter((data.pD) .* data.nC, data.pF; ylabel = "Path %", xlabel = "Expected SCs")

# ╔═╡ c1e97b90-d308-4da0-b462-cad2bc56fa70
noZero = data[(data.pF .!= 0), :]	

# ╔═╡ c025d85c-320c-4b91-83e4-3cb3f3d7e32a
scatter((noZero.pD) .* noZero.nC, noZero.pF; title = "Without Zeros")

# ╔═╡ ab5ddb2b-3b81-421b-bb4d-28b2254f8eff
cor(data.pD, data.pF)

# ╔═╡ 9bde61da-0929-486c-8d7e-b0ba765e760b
nCpF = combine(groupby(data, :nC), :pF => mean; ungroup = true)

# ╔═╡ a8ed4f5e-95da-43e6-bf15-5323ea67eb51
scatter(nCpF.nC, nCpF.pF_mean)

# ╔═╡ da635747-04c6-405c-bb5f-eacb28a6b963
suffix = nCpF[(nCpF.pF_mean .!= 0), :]

# ╔═╡ 29130280-4557-4eec-bb11-a3be629e009a
midSeries = data[(data.nC .== 5000), :]

# ╔═╡ 1ffdf53b-361c-40a0-8ccf-23de94c9812e
scatter(1 .- midSeries.pD, midSeries.pF)

# ╔═╡ Cell order:
# ╠═86e14002-84f5-434c-959b-0ae8cd0cba0e
# ╠═70aae19b-4373-408c-9b8d-678296728e98
# ╠═5dd8bd52-41c0-450d-bfac-4965b5a16419
# ╠═cbccf93a-1470-438a-95ee-51156fad94b1
# ╠═3a37eff8-22ec-4076-904b-f3290b6cde35
# ╠═b7f7c210-57d4-4cc9-b7aa-384481e0103a
# ╠═c5bde7f4-4acd-4614-8374-8fceaa3f32f8
# ╠═d3c6b450-5365-4b0e-a4f1-da50edee6bc2
# ╟─c1e97b90-d308-4da0-b462-cad2bc56fa70
# ╟─c025d85c-320c-4b91-83e4-3cb3f3d7e32a
# ╠═ab5ddb2b-3b81-421b-bb4d-28b2254f8eff
# ╠═b7f34dfe-2177-4ffd-a381-b91bf9d4d5d7
# ╠═9bde61da-0929-486c-8d7e-b0ba765e760b
# ╠═a8ed4f5e-95da-43e6-bf15-5323ea67eb51
# ╠═da635747-04c6-405c-bb5f-eacb28a6b963
# ╠═29130280-4557-4eec-bb11-a3be629e009a
# ╠═1ffdf53b-361c-40a0-8ccf-23de94c9812e
