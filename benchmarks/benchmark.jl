using SDDP
import Dates
import GLPK
import HypothesisTests
import JSON
import PrettyTables

function benchmark_file(filename::String; kwargs...)
    model, _ = SDDP.read_from_file(filename)
    JuMP.set_optimizer(model, GLPK.Optimizer)
    SDDP.train(model; kwargs...)
    log = model.most_recent_training_results.log
    time_weighted_bound = log[1].bound * log[1].time
    for i in 2:length(log)
        time_weighted_bound += log[i].bound * (log[i].time - log[i-1].time)
    end
    return (
        best_bound = log[end].bound,
        total_time = log[end].time,
        total_solves = log[end].total_solves,
        time_weighted_bound = time_weighted_bound / log[end].time,
        bound = map(l -> l.bound, log),
    )
end

function benchmark(; kwargs...)
    solutions = Dict{String,Any}()
    for file in readdir(joinpath(@__DIR__, "models"))
        filename = joinpath(@__DIR__, "models", file)
        solutions[file] = benchmark_file(filename; kwargs...)
    end
    time = Dates.format(Dates.now(), "Y_mm_dd_HHMM")
    data = Dict(
        "date" => time,
        "config" => kwargs,
        "solutions" => solutions,
    )
    open("benchmark_$(time).json", "w") do io
        write(io, JSON.json(data))
    end
    return "benchmark_$(time).json"
end

function _report_columns(filename)
    data = JSON.parsefile(filename)
    models = collect(keys(data["solutions"]))
    d = data["solutions"]
    return (
        models = models,
        best_bound = map(m -> d[m]["best_bound"], models),
        avg_bound = map(m -> d[m]["time_weighted_bound"], models),
        total_time = map(m -> d[m]["total_time"], models),
        total_solves = map(m -> d[m]["total_solves"], models),
        config = data["config"],
    )
end

function _ttest(A, B)
    x = B ./ A
    t = HypothesisTests.OneSampleTTest(convert(Vector{Float64}, x), 1.0)
    return vcat(x, HypothesisTests.pvalue(t), HypothesisTests.confint(t))
end

function _summarize(io, filename_A)
    println(io, "```")
    println(io, "filename: $(filename_A)")
    A = _report_columns(filename_A)
    for (key, val) in A.config
        println(io, "$(key): $(val)")
    end
    println(io, "```\n")
    data = hcat(
        A.models,
        A.best_bound,
        A.avg_bound,
        A.total_time,
        A.total_solves,
    )
    PrettyTables.pretty_table(
        io,
        data;
        header = [
            "Model",
            "Best Bound",
            "Avg. Bound",
            "Time",
            "Solves",
        ],
        tf = PrettyTables.tf_markdown,
    )
    return A
end

function report(A::String, B::String)
    open("report.md", "w") do io
        report(io, A, B)
    end
    return
end

function report(io::IO, filename_A::String, filename_B::String)
    println(io, "# Benchmark report")
    println(io, "\n## Configuration A\n")
    A = _summarize(io, filename_A)
    println(io, "\n## Configuration B\n")
    B = _summarize(io, filename_B)
    println(io, "\n## Comparison B / A\n")
    data = hcat(
        vcat(A.models, "pvalue", "confint"),
        _ttest(A.best_bound, B.best_bound),
        _ttest(A.avg_bound, B.avg_bound),
        _ttest(A.total_time, B.total_time),
        _ttest(A.total_solves, B.total_solves),
    )
    PrettyTables.pretty_table(
        io,
        data;
        header = [
            "Model",
            "Best Bound",
            "Avg. Bound",
            "Time",
            "Solves",
        ],
        tf = PrettyTables.tf_markdown,
    )
    return
end

# filename_A = benchmark(
#     time_limit = 3,
#     stopping_rules = [SDDP.BoundStalling(10, 1e-6)],
# )

# filename_B = benchmark(
#     time_limit = 3,
#     stopping_rules = [SDDP.BoundStalling(10, 1e-6)],
# )

# report(filename_A, filename_B)
