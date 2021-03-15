function _IM.solution_preprocessor(pm::AbstractMCPowerModel, solution::Dict)
    per_unit = _IM.get_data(x -> x["per_unit"], pm.data, pmd_it_name; apply_to_subnetworks = false)
    solution["it"][pmd_it_name]["per_unit"] = per_unit

    for (nw_id, nw_ref) in nws(pm)
        solution["it"][pmd_it_name]["nw"]["$(nw_id)"]["baseMVA"] = nw_ref[:baseMVA]
        solution["it"][pmd_it_name]["nw"]["$(nw_id)"]["conductors"] = nw_ref[:conductors]
    end
end


function _IM.build_solution_values(var::JuMP.Containers.DenseAxisArray{<:JuMP.VariableRef,1})
    return JuMP.value.(var.data)
end


function _IM.build_solution_values(var::JuMP.Containers.DenseAxisArray{<:JuMP.NonlinearExpression,1})
    return JuMP.value.(var.data)
end


function _IM.build_solution_values(var::JuMP.Containers.DenseAxisArray{<:JuMP.GenericAffExpr,1})
    return JuMP.value.(var.data)
end


function _IM.build_solution_values(var::JuMP.Containers.DenseAxisArray{<:Number,1})
    return var.data
end


""
function _sol_data_model_w!(solution::Dict{String,<:Any})
    if haskey(solution, "nw")
        nws_data = solution["nw"]
    else
        nws_data = Dict("0" => solution)
    end

    for (n, nw_data) in nws_data
        if haskey(nw_data, "bus")
            for (i,bus) in nw_data["bus"]
                if haskey(bus, "w")
                    bus["vm"] = sqrt.(bus["w"])
                    delete!(bus, "w")
                end
            end
        end
    end
end


function sol_data_model!(pm::AbstractWModels, solution::Dict{String,<:Any})
    apply_pmd!(_sol_data_model_w!, solution)
end


""
function _sol_data_model_acr!(solution::Dict{String,<:Any})
    if haskey(solution, "nw")
        nws_data = solution["nw"]
    else
        nws_data = Dict("0" => solution)
    end

    for (n, nw_data) in nws_data
        if haskey(nw_data, "bus")
            for (i,bus) in nw_data["bus"]
                if haskey(bus, "vr") && haskey(bus, "vi")
                    bus["vm"] = sqrt.(bus["vr"].^2 + bus["vi"].^2)
                    bus["va"] = atan.(bus["vi"], bus["vr"])

                    delete!(bus, "vr")
                    delete!(bus, "vi")
                end
            end
        end
    end
end


function sol_data_model!(pm::AbstractACRModel, solution::Dict{String,<:Any})
    apply_pmd!(_sol_data_model_acr!, solution)
end


"converts the solution data into the data model's standard space, polar voltages and rectangular power"
function sol_data_model!(pm::AbstractMCPowerModel, solution::Dict{String,<:Any})
    Memento.warn(_LOGGER, "sol_data_model! not defined for power model of type $(typeof(pm))")
end
