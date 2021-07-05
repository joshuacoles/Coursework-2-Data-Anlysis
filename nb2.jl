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

# ╔═╡ 673cd095-420d-4d60-b5b7-ad26b4fa3271
using LsqFit

# ╔═╡ 0c4af89c-7946-46af-a21e-993bc2d4f122
using SpecialFunctions

# ╔═╡ 5dd8bd52-41c0-450d-bfac-4965b5a16419
plotlyjs()

# ╔═╡ cbccf93a-1470-438a-95ee-51156fad94b1
begin
	data = CSV.read("./outq3Wt.csv", DataFrame; header=[:ts, :nC, :pD, :pF])
	data.pD = data.pD ./ 10
	data.pF = data.pF ./ 100
end

# ╔═╡ b7f7c210-57d4-4cc9-b7aa-384481e0103a
scatter(data.nC, data.pF)

# ╔═╡ c5bde7f4-4acd-4614-8374-8fceaa3f32f8
scatter(data.pD, data.pF; xlabel = "pSuper", ylabel = "Path %")

# ╔═╡ d3c6b450-5365-4b0e-a4f1-da50edee6bc2
scatter((data.pD) .* data.nC, data.pF; ylabel = "Path %", xlabel = "Expected SCs")

# ╔═╡ 9bde61da-0929-486c-8d7e-b0ba765e760b
nCpF = combine(groupby(data, :nC), :pF => mean; ungroup = true)

# ╔═╡ 4bf6aea1-3cbf-4dc2-ad7a-f485b779acc2
begin
	# poly = Polynomials::fit(data.nC, data.pF, 20)
	# default(legend = false)
	scatter(nCpF.nC, nCpF.pF_mean)
	# plot!(poly, 100, 625; label = "Fn")
end

# ╔═╡ 56c9a2c4-b0c0-4f7c-a541-71491b71eb9a
velocity = prepend!(diff(nCpF.pF_mean) ./ diff(nCpF.nC), 0)

# ╔═╡ d8312751-9398-47c9-83f8-e12714a79f9e
scatter(nCpF.nC, velocity)

# ╔═╡ 726a000a-aeda-4b1c-8add-46a21dd45063
fn(x, p) = 1 ./ (exp.((p[1] .- x) ./ p[2]) .+ 1)

# ╔═╡ 879993d5-5203-4ffe-8ea6-955812122df7
fit = curve_fit(fn, nCpF.nC, nCpF.pF_mean, [1.0, 3.0])

# ╔═╡ dacd44d1-3a2f-46ae-ba8f-8fc484cd4322
fit.param

# ╔═╡ 28f5c162-2daf-47cd-86f2-a813524f1083
begin
	# poly = Polynomials::fit(data.nC, data.pF, 20)
	# default(legend = false)
	scatter(nCpF.nC, nCpF.pF_mean)
	plot!(data.nC, 0.5 .* (1 .+ erf.((data.nC .- 310) ./ 80)))
	# plot!(poly, 100, 625; label = "Fn")
end

# ╔═╡ Cell order:
# ╠═86e14002-84f5-434c-959b-0ae8cd0cba0e
# ╠═70aae19b-4373-408c-9b8d-678296728e98
# ╠═5dd8bd52-41c0-450d-bfac-4965b5a16419
# ╠═cbccf93a-1470-438a-95ee-51156fad94b1
# ╠═b7f7c210-57d4-4cc9-b7aa-384481e0103a
# ╠═c5bde7f4-4acd-4614-8374-8fceaa3f32f8
# ╠═d3c6b450-5365-4b0e-a4f1-da50edee6bc2
# ╠═9bde61da-0929-486c-8d7e-b0ba765e760b
# ╠═4bf6aea1-3cbf-4dc2-ad7a-f485b779acc2
# ╠═56c9a2c4-b0c0-4f7c-a541-71491b71eb9a
# ╠═d8312751-9398-47c9-83f8-e12714a79f9e
# ╠═673cd095-420d-4d60-b5b7-ad26b4fa3271
# ╠═0c4af89c-7946-46af-a21e-993bc2d4f122
# ╠═726a000a-aeda-4b1c-8add-46a21dd45063
# ╠═879993d5-5203-4ffe-8ea6-955812122df7
# ╠═dacd44d1-3a2f-46ae-ba8f-8fc484cd4322
# ╠═28f5c162-2daf-47cd-86f2-a813524f1083
