### A Pluto.jl notebook ###
# v0.19.37

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 017727dd-b29d-47cf-915a-d4b2010df7a3
# ╠═╡ show_logs = false
using Pkg; Pkg.activate("."); Pkg.instantiate()

# ╔═╡ b4a1a663-ddf5-4ca4-b2da-5198d83ba21e
using HTTP

# ╔═╡ f946a2bc-2414-4957-bd71-501821fe9a6b
using DataFrames: DataFrame, dropmissing

# ╔═╡ 3f6a32d9-84b3-4e0c-843a-b7a3a51a7aa4
using CSV: File

# ╔═╡ 17aa25c7-8f48-4ea6-aac4-2e04eb01a854
using CairoMakie: Figure, Axis, barplot!, lines!, scatter!

# ╔═╡ b986149f-3852-4435-8b0f-89125d56dd9b
using PlutoUI: TableOfContents, Slider, Select, bind, DatePicker

# ╔═╡ 4d808a44-e1c8-418c-b6db-93ff66f32e25
using Dates: Date, week, Day, value, format

# ╔═╡ 04be0c17-6644-4c4d-a12b-7f99e543661a
url = "https://covid.ourworldindata.org/data/owid-covid-data.csv"

# ╔═╡ 2d989fc9-7f8b-4e4d-84e2-2cf72b62de7d
data = String(HTTP.get(url).body)

# ╔═╡ 7d605b98-a3c8-4d5d-89eb-2321a6a76226
df = File(IOBuffer(data)) |> DataFrame

# ╔═╡ 4cc0975e-3afd-4e90-a046-10f76c1504b5
begin
	usa_data = filter(row -> row.location == "United States", df)
	usa_data = dropmissing(usa_data[:, 3:10])
end

# ╔═╡ ee0ab5d5-e5cf-4c97-a275-987ae4b4b8c4
function create_bar_plot(dataframe, column_name)
    fig = Figure(size = (600, 400))
    ax = Axis(fig[1, 1])
    barplot!(ax, 1:length(dataframe.date), dataframe[!, column_name])
    ax.xticks = (1:length(dataframe.date), string.(dataframe.date))
    fig
end

# ╔═╡ 26943204-024a-461c-9fb1-3ed6d824abb5
md"""
Select the column: $(@bind selected_column Select(["total_cases", "new_cases", "new_deaths"], default = "total_cases"))
"""

# ╔═╡ fb70dcdd-c1d3-4e24-a3ef-fda24ad07dc7
create_bar_plot(usa_data, selected_column)

# ╔═╡ a26df715-322a-4f07-ac49-fd0162328d06
function create_line_plot(dataframe, date_range_low, date_range_high)
    # Filter data based on the selected date range
    filtered_data = filter(row -> row.date >= date_range_low && row.date <= date_range_high, dataframe)
    
    # Convert dates to a numerical format (days since the first date in the dataset)
    start_date = minimum(filtered_data.date)
    filtered_data.days_since_start = value.(filtered_data.date .- start_date)
    
    # Create the line plot
    fig = Figure(size = (600, 400))
    ax = Axis(fig[1, 1], title="COVID-19 Total Cases Trend in the US")
    lines!(
        ax, filtered_data.days_since_start, filtered_data.total_cases, color=:blue, linewidth=2)
    scatter!(
        ax, filtered_data.days_since_start, filtered_data.total_cases, color=:red)
    ax.xlabel = "Days since " * format(start_date, "yyyy-mm-dd")
    ax.ylabel = "Total Cases"
    
    return fig
end

# ╔═╡ 355d539d-d1b7-4557-b8c0-3cb26a24ef3a
md"""
Choose Start Date: $(@bind date_range_low DatePicker(default=Date(2020, 3, 1)))
Choose End Date: $(@bind date_range_high DatePicker(default=Date(2020, 4, 1)))
"""

# ╔═╡ 3e456e4f-09a9-425b-bda6-db5328368663
create_line_plot(usa_data, date_range_low, date_range_high)

# ╔═╡ Cell order:
# ╠═017727dd-b29d-47cf-915a-d4b2010df7a3
# ╠═b4a1a663-ddf5-4ca4-b2da-5198d83ba21e
# ╠═f946a2bc-2414-4957-bd71-501821fe9a6b
# ╠═3f6a32d9-84b3-4e0c-843a-b7a3a51a7aa4
# ╠═17aa25c7-8f48-4ea6-aac4-2e04eb01a854
# ╠═b986149f-3852-4435-8b0f-89125d56dd9b
# ╠═04be0c17-6644-4c4d-a12b-7f99e543661a
# ╠═2d989fc9-7f8b-4e4d-84e2-2cf72b62de7d
# ╠═7d605b98-a3c8-4d5d-89eb-2321a6a76226
# ╠═4cc0975e-3afd-4e90-a046-10f76c1504b5
# ╠═ee0ab5d5-e5cf-4c97-a275-987ae4b4b8c4
# ╟─26943204-024a-461c-9fb1-3ed6d824abb5
# ╟─fb70dcdd-c1d3-4e24-a3ef-fda24ad07dc7
# ╠═a26df715-322a-4f07-ac49-fd0162328d06
# ╠═4d808a44-e1c8-418c-b6db-93ff66f32e25
# ╟─355d539d-d1b7-4557-b8c0-3cb26a24ef3a
# ╠═3e456e4f-09a9-425b-bda6-db5328368663
