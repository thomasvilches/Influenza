using Parameters
using DataArrays,DataFrames
include("parameters.jl")
include("PopStruct.jl")
include("functions.jl")

function main(simulationNumber::Int64,P::InfluenzaParameters)

    humans = Array{Human}(P.grid_size_human)
    
    setup_human(humans)
    vaccination(humans,P)
    infected_ctr = zeros(Int64,P.sim_time)
    
    initial=setup_rand_initial_infected(humans,P)### for now, we are using only 1

    for t=1:P.sim_time
        #if P.Model == 1
        contact_dynamic(humans,P)
        #elseif P.Model == 2
            #contact_dynamic2(humans,P)
        #end
        for i=1:P.grid_size_human
            increase_timestate(humans[i],P)
        end

        infected_ctr[t]=update_human(humans,P)

    end
    #first_inf = find(x->x.WhoInf == initial,humans)
    #numb_first_inf = length(first_inf)
    #return infected_ctr,numb_first_inf ##for run.jl in order to check the R0
    return infected_ctr  ###for run2.jl or RunParallel.jl
   

end


