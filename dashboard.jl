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

# ╔═╡ 7aea417a-38e5-41aa-98a5-e0eee3570f87
# ╠═╡ show_logs = false
using Pkg; Pkg.activate("."); Pkg.instantiate()

# ╔═╡ 658318e9-055f-45e4-b616-0e4d191cf4f2
using HTTP

# ╔═╡ 2149e5cf-399b-4e53-a712-5f0abfecef9a
using DataFrames: DataFrame, dropmissing

# ╔═╡ 2399d4c8-ff36-4d7f-a92a-56f50164f9c9
using CSV: File

# ╔═╡ 20552a45-0c1e-4576-b303-7a962587cf9b
using Dates: Date, week, Day, value, format

# ╔═╡ 4cdac49c-7da0-49f4-82e2-80e1a59f22f4
using CairoMakie: Figure, Axis, barplot!, lines!, scatter!

# ╔═╡ 2f142e5f-4782-4b4f-9de3-f8f966715281
using PlutoUI: TableOfContents, Slider, Select, bind, DatePicker

# ╔═╡ 1bca1617-8462-4d03-8d79-fbeb8e7a56fc
md"""
Select the column: $(@bind selected_column Select(["total_cases", "new_cases", "new_deaths"], default = "total_cases"))
"""

# ╔═╡ e829079f-196c-47ed-b7e4-fdd356b3cfd4
md"""
Choose Start Date: $(@bind date_range_low DatePicker(default=Date(2020, 3, 1)))
Choose End Date: $(@bind date_range_high DatePicker(default=Date(2020, 4, 1)))
"""

# ╔═╡ bf022d2c-0278-453b-b85d-813e64411555
url = "https://covid.ourworldindata.org/data/owid-covid-data.csv";

# ╔═╡ ff9257cf-cf72-4fe2-b695-2ec8a6d647e0
data = String(HTTP.get(url).body);

# ╔═╡ 30324c41-2f77-47b8-a6bb-8231b28ca564
df = File(IOBuffer(data)) |> DataFrame;

# ╔═╡ 27fee879-8283-443e-8fcd-6d880b8a688f
begin
	usa_data = filter(row -> row.location == "United States", df)
	usa_data = dropmissing(usa_data[:, 3:10])
end;

# ╔═╡ 4e0dc514-d569-4e02-838d-0f7eba7387f7
function create_bar_plot(dataframe, column_name)
    fig = Figure(size = (600, 400))
    ax = Axis(fig[1, 1])
    barplot!(ax, 1:length(dataframe.date), dataframe[!, column_name])
    ax.xticks = (1:length(dataframe.date), string.(dataframe.date))
    fig
end;

# ╔═╡ 612ce7fc-68e5-47db-8b62-374ac69c13e5
create_bar_plot(usa_data, selected_column)

# ╔═╡ af60e6a2-bfb1-42bc-9e15-ba46c0ee4947
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
end;

# ╔═╡ 6664f928-c98a-4fc5-b6df-17209e899f90
create_line_plot(usa_data, date_range_low, date_range_high)

# ╔═╡ Cell order:
# ╟─1bca1617-8462-4d03-8d79-fbeb8e7a56fc
# ╟─612ce7fc-68e5-47db-8b62-374ac69c13e5
# ╟─e829079f-196c-47ed-b7e4-fdd356b3cfd4
# ╟─6664f928-c98a-4fc5-b6df-17209e899f90
# ╟─7aea417a-38e5-41aa-98a5-e0eee3570f87
# ╟─658318e9-055f-45e4-b616-0e4d191cf4f2
# ╟─2149e5cf-399b-4e53-a712-5f0abfecef9a
# ╟─2399d4c8-ff36-4d7f-a92a-56f50164f9c9
# ╟─20552a45-0c1e-4576-b303-7a962587cf9b
# ╟─4cdac49c-7da0-49f4-82e2-80e1a59f22f4
# ╟─2f142e5f-4782-4b4f-9de3-f8f966715281
# ╟─bf022d2c-0278-453b-b85d-813e64411555
# ╟─ff9257cf-cf72-4fe2-b695-2ec8a6d647e0
# ╟─30324c41-2f77-47b8-a6bb-8231b28ca564
# ╟─27fee879-8283-443e-8fcd-6d880b8a688f
# ╟─4e0dc514-d569-4e02-838d-0f7eba7387f7
# ╟─af60e6a2-bfb1-42bc-9e15-ba46c0ee4947
