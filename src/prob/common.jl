"alias to run_model in PowerModels with multiconductor=true, and transformer ref extensions added by default"
function solve_mc_model(data::Dict{String,<:Any}, model_type::Type, solver, build_mc::Function; ref_extensions::Vector{<:Function}=Vector{Function}([]), make_si=!get(data, "per_unit", false), multinetwork::Bool=false, kwargs...)::Dict{String,Any}
    if get(data, "data_model", MATHEMATICAL) == ENGINEERING
        data_math = transform_data_model(data; build_multinetwork=multinetwork)

        result = run_model(data_math, model_type, solver, build_mc; ref_extensions=[ref_add_arcs_transformer!, ref_add_arcs_switch!, ref_add_connections!, ref_extensions...], multiconductor=true, multinetwork=multinetwork, kwargs...)

        result["solution"] = transform_solution(result["solution"], data_math; make_si=make_si)
    elseif get(data, "data_model", MATHEMATICAL) == MATHEMATICAL
        result = run_model(data, model_type, solver, build_mc; ref_extensions=[ref_add_arcs_transformer!, ref_add_arcs_switch!, ref_add_connections!, ref_extensions...], multiconductor=true, multinetwork=multinetwork, kwargs...)
    end

    return result
end


"alias to run_model in PowerModels with multiconductor=true, and transformer ref extensions added by default"
function solve_mc_model(file::String, model_type::Type, solver, build_mc::Function; ref_extensions::Vector{<:Function}=Vector{Function}([]), kwargs...)::Dict{String,Any}
    return solve_mc_model(parse_file(file), model_type, solver, build_mc; ref_extensions=ref_extensions, kwargs...)
end


"depreciation message for run_mc_model"
function run_mc_model(data::Union{String,Dict{String,<:Any}}, model_type::Type, solver, build_mc::Function; kwargs...)::Dict{String,Any}
    @warn "run_mc_model is being depreciated in favor of solve_mc_model, please update your code accordingly"
    return solve_mc_model(data, model_type, solver, build_mc; kwargs...)
end
