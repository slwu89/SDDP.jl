using Kokako, Test, GLPK

@testset "Forward Pass" begin
    model = Kokako.PolicyGraph(Kokako.LinearGraph(2);
                sense = :Max,
                bellman_function = Kokako.AverageCut(upper_bound=100.0),
                optimizer = with_optimizer(GLPK.Optimizer)
                    ) do node, stage
        @variable(node, x, Kokako.State, root_value=0.0)
        @stageobjective(node, x.out)
        Kokako.parameterize(node, stage * [1, 3], [0.5, 0.5]) do ω
            JuMP.set_upper_bound(x.out, ω)
        end
    end
    scenario_path, sampled_states, cumulative_value = Kokako.forward_pass(model,
        Kokako.Options(model, Dict(:x=>1.0), Kokako.InSampleMonteCarlo()))
    simulated_value = 0.0
    for ((node_index, noise), state) in zip(scenario_path, sampled_states)
        @test state[:x] == noise
        simulated_value += noise
    end
    @test simulated_value == cumulative_value
end

@testset "solve" begin
    model = Kokako.PolicyGraph(Kokako.LinearGraph(2),
                bellman_function = Kokako.AverageCut(lower_bound=0.0),
                optimizer = with_optimizer(GLPK.Optimizer)
                    ) do node, stage
        @variable(node, x >= 0, Kokako.State, root_value=0.0)
        @stageobjective(node, x.out)
        Kokako.parameterize(node, stage * [1, 3], [0.5, 0.5]) do ω
            JuMP.set_lower_bound(x.out, ω)
        end
    end
    status = Kokako.train(model; iteration_limit = 4)
    Kokako.write_bellman_to_file(model, "model.bellman.json")
    rm("model.bellman.json")
end
