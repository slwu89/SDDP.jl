# [API Reference](@id api_reference_list)

## Policy graphs

```@docs
SDDP.Graph
SDDP.add_node
SDDP.add_edge
SDDP.add_ambiguity_set
SDDP.LinearGraph
SDDP.MarkovianGraph
SDDP.UnicyclicGraph
SDDP.LinearPolicyGraph
SDDP.MarkovianPolicyGraph
SDDP.PolicyGraph
```

## Subproblem definition

```@docs
@stageobjective
SDDP.parameterize
SDDP.add_objective_state
SDDP.objective_state
SDDP.Noise
```

## Training the policy

```@docs
SDDP.numerical_stability_report
SDDP.train
SDDP.termination_status
SDDP.write_cuts_to_file
SDDP.read_cuts_from_file
SDDP.write_log_to_csv
```

### [Stopping rules](@id api_stopping_rules)

```@docs
SDDP.AbstractStoppingRule
SDDP.stopping_rule_status
SDDP.convergence_test
SDDP.IterationLimit
SDDP.TimeLimit
SDDP.Statistical
SDDP.BoundStalling
SDDP.StoppingChain
SDDP.SimulationStoppingRule
```

### Sampling schemes

```@docs
SDDP.AbstractSamplingScheme
SDDP.sample_scenario
SDDP.InSampleMonteCarlo
SDDP.OutOfSampleMonteCarlo
SDDP.Historical
SDDP.PSRSamplingScheme
SDDP.SimulatorSamplingScheme
```

### Parallel schemes

```@docs
SDDP.AbstractParallelScheme
SDDP.Serial
SDDP.Asynchronous
```

### Forward passes

```@docs
SDDP.AbstractForwardPass
SDDP.DefaultForwardPass
SDDP.RevisitingForwardPass
SDDP.RiskAdjustedForwardPass
SDDP.AlternativeForwardPass
SDDP.AlternativePostIterationCallback
```

### Risk Measures

```@docs
SDDP.AbstractRiskMeasure
SDDP.adjust_probability
```

### Duality handlers

```@docs
SDDP.AbstractDualityHandler
SDDP.ContinuousConicDuality
SDDP.LagrangianDuality
SDDP.StrengthenedConicDuality
SDDP.BanditDuality
```

## Simulating the policy

```@docs
SDDP.simulate
SDDP.calculate_bound
SDDP.add_all_cuts
```

## Decision rules

```@docs
SDDP.DecisionRule
SDDP.evaluate
```

## Visualizing the policy

```@docs
SDDP.SpaghettiPlot
SDDP.add_spaghetti
SDDP.publication_plot
SDDP.ValueFunction
SDDP.evaluate(::SDDP.ValueFunction, ::Dict{Symbol,Float64})
SDDP.plot
```
## Debugging the model

```@docs
SDDP.write_subproblem_to_file
SDDP.deterministic_equivalent
```

## StochOptFormat

```@docs
SDDP.write_to_file
SDDP.read_from_file
Base.write(::IO, ::SDDP.PolicyGraph)
Base.read(::IO, ::Type{SDDP.PolicyGraph})
SDDP.evaluate(::SDDP.PolicyGraph{T}, ::SDDP.ValidationScenarios{T}) where {T}
SDDP.ValidationScenarios
SDDP.ValidationScenario
```
