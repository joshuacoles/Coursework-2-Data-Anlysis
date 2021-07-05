### A Pluto.jl notebook ###
# v0.14.3

using Markdown
using InteractiveUtils

# ╔═╡ 86e14002-84f5-434c-959b-0ae8cd0cba0e
begin
	using CSV
	using DataFrames
	using Plots
	using Statistics
	
	plotlyjs()
end

# ╔═╡ 77044d39-b9a3-4e26-a33c-06c989bd7687
md"""
## Expanded Coursework Stats

I ended up enjoying this component of the coursework substantially, possibly to the detriment of the rest in-fact. I have included some of these findings and graph in the report PDF itself, but as it is of PDF form, the 3D interactive ones can not be transferred over, much to my saddness.

This was a wonderful chance to learn some more Julia and practice some investigative thinking, and I wish I could have devoted more time to this.

The document below is presented in a narrative form, it represents the steps taken if not all the work along the way, it can be a bit inconsistent in places but I hope it is mildly interesting if nothing else.
"""

# ╔═╡ 27d6a9f5-3340-4045-afce-f12d368f5367
begin
	function loadData(csv, dim)
		headings = [:ts, :nC, :pD, :pF]
	
		df = CSV.read(csv, DataFrame; header=headings)
		df.pD = df.pD ./ 10
		df.pF = df.pF ./ 100
		df.nnC = df.nC ./ (dim * dim)
	
		return df
	end
	
	d10 = loadData("dc-10-10-0-100.csv", 10)
	d15 = loadData("dc-15-15-0-225.csv", 15)
	d25 = loadData("dc-25-25-0-625.csv", 25)
	d50 = loadData("dc-50-50-0-2500.csv", 50)
	d100 = loadData("dc-100-100-0-10000.csv", 100)
	
	labels = Dict(
		:nC => "# of Conductors",
		:nnC => "% Conductors",
		:pD => "fSC",
		:pF => "Paths Found"
	)
		
	
	md"> Data"
end

# ╔═╡ 283b3bcb-4cad-4cff-a40d-5a3b3e7bcd71
begin
	using LsqFit
	using SpecialFunctions
	p0 = [1.0,1.0]
	logistic(nC, p) = 1 ./ (1 .+ exp.(-1 .* (nC .- p[1]) ./ p[2]))
	norm_cdf(nC, p) = 0.5 .* (1 .+ erf.((nC .- p[1]) ./ (p[2] * sqrt(2))))
	
	p01 = d25[(d25.pD .== 0.3), :]
	plot(p01.nnC, p01.pF, label = "Raw Data")

	fit01 = curve_fit(logistic, p01.nnC, p01.pF, p0).param
	plot!(p01.nnC, logistic(p01.nnC, fit01), label = "Logistic Curve", linewidth=2)
	fit02 = curve_fit(norm_cdf, p01.nnC, p01.pF, p0).param
	plot!(p01.nnC, norm_cdf(p01.nnC, fit02), label = "Normal CDF", linewidth=2)
end

# ╔═╡ 9cf16d02-c174-4764-9262-92e4af17f0cf
begin
	l = @layout [a b ; c d]

	a = plot(d25.nC, d25.ts,
		legend = :topleft,
		linecolor = :purple,
		title = "Time Data",
		label = "T(N)"
		# xlabel = labels[:nC],
		# ylabel = "Time per 100 samples"
	)
	
	using Polynomials
	poly1 = fit(d25.nC, d25.ts, 1)
	poly2 = fit(d25.nC, d25.ts, 2)
	poly3 = fit(d25.nC, d25.ts, 3)

	b = plot(0:625, poly1.(0:625), title = "O(n)", label = "", linestyle = :dash, linewidth = 3)
	plot!(b, d25.nC, d25.ts,
		legend = :topleft,
		linecolor = :purple, label = ""
	)
	c = plot(0:625, poly2.(0:625), title = "O(n^2)", label = "", linestyle = :dash, linewidth = 3)
	plot!(c, d25.nC, d25.ts,
		legend = :topleft,
		linecolor = :purple, label = ""
	)


	d = plot(0:625, poly3.(0:625), title = "O(n^3)", label = "", linestyle = :dash, linewidth = 3, linecolor = :red)
	plot!(d, d25.nC, d25.ts,
		legend = :topleft,
		linecolor = :purple, label = ""
	)


	plot(a, b, c, d, layout = l)
end

# ╔═╡ 611f5501-a3f5-4eb1-b8f1-da1577bbb372
md"
## Investigation

Our algorithm is $O(n^3)$ in number of conductors, which is itself $n^2$ to the size of the square grid. lets first start *smallish* with a grid size of $25 \times 25$ where we will hopfully be able to see some meaningful relations between our variables.
" 

# ╔═╡ b7f7c210-57d4-4cc9-b7aa-384481e0103a
scatter(d25.nC, d25.pD, d25.pF; 
	xlabel = "# of Conductors",
	ylabel = "% Super Conductors",
	zlabel = "Paths Found",
	title = "25 x 25 Grid Data",
	group=d25.pD
)

# ╔═╡ a53040be-ab37-4dee-af55-90a2d97f7b7c
md"""
This was fruitful! We can clearly see at least three independent patterns:

1. The behaviour of the path percentage, at constant $f_{SC}$, follows what appears to be an S-curve of some variety.
2. These S-curves are only really relevant in some "middle" section of the plot, at the very low and high number of conductors the percentages are effectively $0\%$ or $100\%$.
3. The curves themselves seem to be offset from each other by some amount, dependent on the $f_{SC}$ value.

We can see these patterns more cleanly by the following two plots:
"""

# ╔═╡ 4e14ae2e-e183-4a3e-a577-8527bca1d2b5
plot(d25.nC, d25.pD, d25.pF; 
		xlabel = "# of Conductors",
		ylabel = "% Super Conductors",
		zlabel = "Paths Found",
		group=d25.pD
)

# ╔═╡ 18a01fb2-94f4-4c30-8036-c29cb5ceb854
scatter(
	d25.nC,
	d25.pF,
	group=d25.pD,
	xlabel = "Number of Conductors",
	ylabel = "Paths Found",
	title = "2D Representation of 25 x 25 Mass Sample"
)

# ╔═╡ cff13dbd-3c48-4625-b390-5d6249cabeff
md"""
The next thing to check is that this pattern does indeed occur at the $100 \times 100$ grid requested in the brief. Here we run into an issue, previously we took a "give me everything" approach to data-sampling: this does not work with such a large grid. In fact it was attempted but I had to cut the program short due to quite how long it ran. Presented below is the data it captured in time it did run.
"""

# ╔═╡ e557a8e6-fa5e-4542-af7c-c6538c53dc96
scatter(d100.nC, d100.pD, d100.pF; 
	xlabel = "# of Conductors",
	ylabel = "% Super Conductors",
	zlabel = "Paths Found",
	group=d100.pD,
	xlims = [0, 100 ^ 2]
)

# ╔═╡ f7fd1bde-ac1f-46d4-9d74-b747c4431712
md"""
You can see that we only reached about $N = 6700$ before the program had to be terminated. We can however see a similar pattern emerging in the data and did in-fact manage to capture the region of interest (the middle curve section), albeit with less granularity as our step size ratio was twice as large ($100 / 1000$ vs $1 / 50$).

This similarity does raise interesting points however, what occurs if we plot these in terms of the fraction of cells which are conductors, as opposed to the raw number of conductors itself, do they line up?

Below we see plotted as balls, the incomplete data for the $100 \times 100$ grid, and lines the complete data for the smaller $25 \times 25$ data.
"""

# ╔═╡ c29b590b-4606-4308-b9a1-cda7d3dd386c
begin
	scatter(
		xlabel = "# of Conductors",
		ylabel = "% Super Conductors",
		zlabel = "Paths Found",
		legend = :none
	)

	plot!(d25.nnC, d25.pD, d25.pF; 
		group=d25.pD,
	)	

	scatter!(d100.nnC, d100.pD, d100.pF; 
		group=d100.pD
	)	
end

# ╔═╡ 7ec46d37-ada4-4a0d-a956-3fae784c8b50
md"""
From this we can see that from the looks of things they do in fact line up, proving that the phenomena appears to be *scale independent*. This allows us to use the smaller more computationally accessible grids as stand-ins for the larger brief specified grid, as long as we verify any findings. And further we can use the multiple datasets to provide additional data to our readings and thus improve our accuracy.

> Note that unless stated otherwise all calculations have been performed on the $25 \times 25$ dataset from here on out.
"""

# ╔═╡ fc20d42d-e6dc-4381-bb96-e2f9c4ac9334
md"""
## Quantitative & Theoretical Reasoning

Now we get to the tough bit, trying to decide on a model to fit onto this data. We suspect this model will have as its parameters the percentage of cells occupied by a conductor, and the percentage of those which are super conductors. These will be expressed likely in two "fit-paramters" (for example $\mu$ and $\sigma$ for a normal distribution), which we would aim to get expressions for in terms of the two percentages.

The issue is however that we can fit many different curves to this dataset. In general almost any [Sigmoid Function](https://en.wikipedia.org/wiki/Sigmoid_function#Examples) will fit suitably well to the data. To illustrate this we have fit both a Logistic Curve and Normal CDF to the data, shown below.
"""

# ╔═╡ 7c7cfc68-8d99-4e7b-bb18-9af411dce799
md"""
The nature of the curve as a Sigmoid does present one useful avenue for exploration however, since as wikipedia notes they are often Cumulative Distribution Functions, implying this might be related somewhat to what we are delaing with now.

But first a simpler problem, the offsets.
"""

# ╔═╡ 89aeca53-f27a-470b-a219-65284277bef4
md"""
### Offset

As we noted before these curves all seemed to be offset from each other by some amount, this would seem to be a data point which is much easier to quanitfy.

We do this by focusing on the point in a given curve closest to $0.5$, displaying them as so.
"""

# ╔═╡ 9e567334-863d-4242-ba89-9cb3969849ba
begin
	function offsetStats(df)
		df.halfDiff = abs.(df.pF .- 0.5)
		halfPoints = combine(groupby(df, :pD), sdf -> sdf[argmin(sdf.halfDiff), :])

		function halfOf(pd)
			halfPoints[(halfPoints.pD .== pd), :].nnC[1]
		end
	
		df.offsetnnC = df.nnC .- halfOf.(df.pD)
		return halfPoints
	end
	
	halfPoints25 = offsetStats(d25)
	scatter(
		halfPoints25.pD,
		halfPoints25.nnC,
		xlabel = "% Super Conductors",
		ylabel = "% Conductors ",
		label = "",
		title = "% Conductors required for 50% Formation"
	)
end

# ╔═╡ ad1d81ec-80f3-4167-a3a3-df2d554f61ad
md"""
Here we see that apart from the value at $0.9$ these form a smooth curve, this is promising. Again we side step the issue of fitting and instead use these half point values to align the curves seen before to compare their relevative "curviness" (a very rigorous term I know). 
"""

# ╔═╡ bf6f3acd-552c-4594-b405-773fb7f01ed0
begin
	plot(
		d25.offsetnnC,
		d25.pF,
		group=d25.pD,
		xlabel = "Offset $(labels[:nnC])",
		ylabel = labels[:pF],
		legend = :none
	)
end

# ╔═╡ 4e47e5de-6610-4108-ad34-8f94cef3490d
md"""
This (while is is rather messy) shows that effectivly the only paramter actually changing here is the offset, the "curviness" seems to be at least approximatly constant, and is either a constant of the process, or possibly some unknown variable.

To invesitgate this we can apply the same logic to curves in a different data set, say the larger (but incomplete) $100 \times 100$ set.

Note that the curve is offset from the one above as we are obviously lacking data for the higher $N$ values.
"""

# ╔═╡ 6a253e12-f93d-4d41-a633-eed176247b1c
begin
	offsetStats(d100)
	
	plot(
		d100.offsetnnC,
		d100.pF,
		group=d100.pD,
		xlabel = "Offset $(labels[:nnC])",
		ylabel = labels[:pF],
		legend = :none,
		title = "100 x 100 offset relation"
	)
end

# ╔═╡ d45df6bb-7bb5-4575-89bb-3ff839dfce42
md"And now overlaying the two (green being $100 \times 100$, blue $25 \times 25$, and purple $15 \times 15$):"

# ╔═╡ f62dc84a-2133-4881-a680-feee5b7fb158
begin
	plot(
		xlabel = "Offset $(labels[:nnC])",
		ylabel = labels[:pF],
		legend = :none,
		title = "Dimension dependent offset relation"
	)
	
	plot!(
		d100.offsetnnC,
		d100.pF,
		group=d100.pD,
		linecolour = :green
	)

	plot!(
		d25.offsetnnC,
		d25.pF,
		group=d25.pD,
		linecolour = :blue,
	)

	offsetStats(d15)
	
	plot!(
		d15.offsetnnC,
		d15.pF,
		group=d15.pD,
		linecolour = :purple,
	)
end

# ╔═╡ f58944d6-b429-4903-a9c4-086eeef2d046
md"""
Here we notice (most especially in the corners of the curve) a variation between the curves of different grid size, implying that while the "curviness" is independent of $n$ and $f_{SC}$, it *does* appear to be dependent on the size of the grid. With smaller grids being more curvy, and larger grids having a steeper less curvy incline.
"""

# ╔═╡ de9e3fa7-c54e-48eb-9897-16dddc29261a
md"""
## An ending of sorts

I am afraid it is at this point I must end, as I have to return to the other parts of the report, leaving the stats behind.

However as a guide of where this exploration could be taken further. The offsets appear to be distributed on an exponential decay, although I cannot yet justify this. I would suspect that the sigmoid function present here is in fact the CDF of a normal distribution. As a rather hand wavy justification of this:

- The addition of a single conductor will not remove any previously valid conduction path, hence it makes sense it would be cumulative in some variety, building on the paths of the last.
- Further as we are dealing with a finite discrete system of discrete states, we will most likely be dealing with combinatorics: permutation and combinations. These when taken to the large number limit often end up in normal distributions (as seen when the Binomial goes to the normal at $n$ large, $p \approx 0.5$).
- I do not have any logic for the "curviness" of the curve, this would be expressed in the standard deviation of the CDF. This was discovered later in the exploration process and thus I have no investigated much. However it would be interesting to see if this is correlated more cleanly with $L_x$, $L_y$ or their product.
"""

# ╔═╡ 223209af-3c97-4db1-93c6-b0a45af8a7a3
md"""
## An aside on time complexity

With all of the data in the program, we outputting approximate time values, thus allowing us to fit time complexity curves to the data.
"""

# ╔═╡ b0281d03-a9f0-4684-bda8-68fc0bdfc08d
md"""
## Scratch Board (personal tests)
"""

# ╔═╡ f92b5bc3-770a-45aa-b208-bd8dec1448d1
begin
	ta = loadData("/Users/joshuacoles/Developer/checkouts/jc3091/cw-2-c/stats/dc-12-12-0-143.csv", 12)
	tb = loadData("/Users/joshuacoles/Developer/checkouts/jc3091/cw-2-c/stats/dc-12-12-0-144.csv", 12)
	
	plot(ta.nC, ta.pD, ta.pF)
	plot!(tb.nC, tb.pD, tb.pF)
end

# ╔═╡ ee20cd0a-47b8-48cc-bb9f-c77c81e9304f
begin
	mexp(t, p) = p[1] .+ p[2] .* t .+ p[3] .* t .* t
	mexpp = curve_fit(mexp, halfPoints25.pD, halfPoints25.nnC, [1.0,1.0, 1.0]).param
	scatter(
		halfPoints25.pD,
		halfPoints25.nnC,
		xlabel = "% Super Conductors",
		ylabel = "% Conductors ",
		label = "",
		title = "% Conductors required for 50% Formation"
	)
	plot!(0:0.01:1, mexp(0:0.01:1, mexpp), label = "Quadratic Fit")
end

# ╔═╡ 4533388e-2005-4dc4-8fe5-9a0378703fde
begin
	model(t, p) = 0.5 .* (1 .+ erf.((t .- p[1]) ./ (p[2] * sqrt(2))))
	
	plot(
		xlabel = "Offset $(labels[:nnC])",
		ylabel = labels[:pF],
		title = "Dimension dependent offset relation"
	)

	function hey(dX)
		fit = curve_fit(model, d100.offsetnnC, d100.pF, [0.5, 0.5])
		param = fit.param
	
	
		plot!(
			dX.offsetnnC,
			dX.pF,
			group=dX.pD,
			linecolour = :green
		)
	
		plot!(-1:0.01:1, model(-1:0.01:1, param))
	end
	
	hey(d25)
	hey(d100)
end

# ╔═╡ b1402351-2b5f-4403-9b24-98f67b289002
begin
	plot(
		xlabel = "Offset $(labels[:nnC])",
		ylabel = labels[:pF],
		title = "Dimension dependent offset relation"
	)
	
	function symplot(dX)
		plot!(
				dX.offsetnnC,
				dX.pF,
				group=dX.pD,
				linecolour = :green
		)
	
		plot!(
				-dX.offsetnnC,
				1 .- dX.pF,
				group=dX.pD,
				linecolour = :red
		)
	end
	
	symplot(d15)
end

# ╔═╡ Cell order:
# ╟─77044d39-b9a3-4e26-a33c-06c989bd7687
# ╠═86e14002-84f5-434c-959b-0ae8cd0cba0e
# ╟─27d6a9f5-3340-4045-afce-f12d368f5367
# ╟─611f5501-a3f5-4eb1-b8f1-da1577bbb372
# ╟─b7f7c210-57d4-4cc9-b7aa-384481e0103a
# ╟─a53040be-ab37-4dee-af55-90a2d97f7b7c
# ╟─4e14ae2e-e183-4a3e-a577-8527bca1d2b5
# ╠═18a01fb2-94f4-4c30-8036-c29cb5ceb854
# ╟─cff13dbd-3c48-4625-b390-5d6249cabeff
# ╟─e557a8e6-fa5e-4542-af7c-c6538c53dc96
# ╟─f7fd1bde-ac1f-46d4-9d74-b747c4431712
# ╠═c29b590b-4606-4308-b9a1-cda7d3dd386c
# ╟─7ec46d37-ada4-4a0d-a956-3fae784c8b50
# ╟─fc20d42d-e6dc-4381-bb96-e2f9c4ac9334
# ╠═283b3bcb-4cad-4cff-a40d-5a3b3e7bcd71
# ╟─7c7cfc68-8d99-4e7b-bb18-9af411dce799
# ╟─89aeca53-f27a-470b-a219-65284277bef4
# ╠═9e567334-863d-4242-ba89-9cb3969849ba
# ╟─ad1d81ec-80f3-4167-a3a3-df2d554f61ad
# ╟─bf6f3acd-552c-4594-b405-773fb7f01ed0
# ╟─4e47e5de-6610-4108-ad34-8f94cef3490d
# ╟─6a253e12-f93d-4d41-a633-eed176247b1c
# ╟─d45df6bb-7bb5-4575-89bb-3ff839dfce42
# ╠═f62dc84a-2133-4881-a680-feee5b7fb158
# ╟─f58944d6-b429-4903-a9c4-086eeef2d046
# ╟─de9e3fa7-c54e-48eb-9897-16dddc29261a
# ╟─223209af-3c97-4db1-93c6-b0a45af8a7a3
# ╠═9cf16d02-c174-4764-9262-92e4af17f0cf
# ╟─b0281d03-a9f0-4684-bda8-68fc0bdfc08d
# ╠═f92b5bc3-770a-45aa-b208-bd8dec1448d1
# ╠═ee20cd0a-47b8-48cc-bb9f-c77c81e9304f
# ╠═4533388e-2005-4dc4-8fe5-9a0378703fde
# ╠═b1402351-2b5f-4403-9b24-98f67b289002
