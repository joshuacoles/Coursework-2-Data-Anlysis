### A Pluto.jl notebook ###
# v0.14.3

using Markdown
using InteractiveUtils

# ╔═╡ 680829f6-a82f-11eb-0de5-09206004c651
begin
	using CSV
	using DataFrames
	using Plots
end

# ╔═╡ 859b2e28-4d2c-4019-a6e9-2ce75597d42e
using Polynomials

# ╔═╡ af3e1452-164f-4d0d-8749-110655b6f221
plotlyjs()

# ╔═╡ e3cd2a2e-e041-47cf-bafe-e4fa1e3d1ddd
begin
	data = CSV.read("./dc-100-100-0-10000.csv", DataFrame; header=[:ts, :nC, :pD, :pF])
	data.pD = data.pD ./ 10
	data.pF = data.pF ./ 100
	data.ts = data.ts .- minimum(data.ts)
end

# ╔═╡ f7e5db7a-9194-4382-8c54-cfe219b29a47
scatter(data.nC, data.ts)

# ╔═╡ 643daeda-20b4-4994-ae56-9965c92d37db
deltaTs = prepend!(diff(data.ts), 0)

# ╔═╡ 50d9df64-bd6b-4a35-b45b-7da452852156
scatter(data.nC, deltaTs)

# ╔═╡ b6cef758-fc63-4418-8d72-ae02bafaab6f
scatter(data.nC, data.pD, deltaTs)

# ╔═╡ 4abe8c91-ceef-49f2-980c-ba9846154b00
poly = fit(data.nC, deltaTs, 2)

# ╔═╡ e7a1091c-968c-4b93-8589-1fd6f3364607
begin
	scatter(data.nC, deltaTs)
	plot!(poly, 0, 900; label = "Fn")
end

# ╔═╡ Cell order:
# ╠═680829f6-a82f-11eb-0de5-09206004c651
# ╠═af3e1452-164f-4d0d-8749-110655b6f221
# ╠═e3cd2a2e-e041-47cf-bafe-e4fa1e3d1ddd
# ╠═f7e5db7a-9194-4382-8c54-cfe219b29a47
# ╠═643daeda-20b4-4994-ae56-9965c92d37db
# ╠═50d9df64-bd6b-4a35-b45b-7da452852156
# ╠═b6cef758-fc63-4418-8d72-ae02bafaab6f
# ╠═859b2e28-4d2c-4019-a6e9-2ce75597d42e
# ╠═4abe8c91-ceef-49f2-980c-ba9846154b00
# ╠═e7a1091c-968c-4b93-8589-1fd6f3364607
