# Coursework 2 Data analysis

These are notebooks written in [Julia](https://julialang.org) using [Pluto](pluto.jl).

It is currently uploaded as is and is thus a mess, however the main points are as follows:

- The main notebook is `nb2-100-100.jl`.
- The csv files have the following columns
  - `:ts`, Timestamp information: used to approximate time complexity.
  - `:nC`, the number of conductors used in the simulation.
  - `:pD`, percentage that are super conductors (`D` for diagonal), stored as numerator of x/10.
  - `:pF`, percentage of simulations which formed a path, stored as numerator of x/100.

See `https://github.com/joshuacoles/Coursework-2/tree/c` for the code to generate this data.
