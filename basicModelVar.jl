using Parameters
using DataArrays,DataFrames
using Distributions
include("parameters.jl")
include("PopStruct.jl")
include("functions.jl")

function main(simulationNumber::Int64,P::InfluenzaParameters)
    println("$simulationNumber")
    humans = Array{Human}(P.grid_size_human)
    
    setup_human(humans)
    setup_demographic(humans,P)
    vaccination(humans,P)

    latent_ctr = zeros(Int64,P.sim_time)##vector of results
    symp_ctr = zeros(Int64,P.sim_time)
    asymp_ctr = zeros(Int64,P.sim_time)
    
    initial=setup_rand_initial_latent(humans,P)### for now, we are using only 1

    for t=1:P.sim_time
        #if P.Model == 1
        contact_dynamic(humans,P)
       
        for i=1:P.grid_size_human
            increase_timestate(humans[i],P)
        end

        latent_ctr[t],symp_ctr[t],asymp_ctr[t]=update_human(humans,P)

    end
    first_inf = find(x-> x.WhoInf == initial && x.WentTo == SYMP,humans)
    numb_first_inf = length(first_inf)
    #arqR0 = open(string("Data1/R0/R0check","$(P.Prob_transmission)","sim","$simulationNumber",".dat"),"w")
    #println(arqR0,"$numb_first_inf")
    #close(arqR0)

    return latent_ctr,symp_ctr,asymp_ctr  ###for run2.jl or RunParallel.jl Run2Parallel.jl
   

end


