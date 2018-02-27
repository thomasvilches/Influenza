addprocs(4)

@everywhere using Parameters
@everywhere using DataArrays,DataFrames
@everywhere using QuadGK
@everywhere using Distributions
@everywhere using StatsBase

println("added $(nworkers()) processors")
info("starting @everywhere include process...")
@everywhere include("basicModel.jl")
################## To run this files, You must check the return of BasicModel.jl
#######################3


function run_main(P::InfluenzaParameters,numberofsims::Int64)
    
    results = pmap(x->main(x,P),1:numberofsims,distributed = true)

    dataprocess(results,P,numberofsims)
end

function dataprocess(results,P::InfluenzaParameters,numberofsims)

    resultsL = Matrix{Int64}(P.sim_time,numberofsims)
    resultsA = Matrix{Int64}(P.sim_time,numberofsims)
    resultsS = Matrix{Int64}(P.sim_time,numberofsims)

    for i=1:numberofsims
        resultsL[:,i] = results[i][1]
        resultsS[:,i] = results[i][2]
        resultsA[:,i] = results[i][3]
    end
    

    writedlm(string("Data1/result","$(P.Prob_transmission)","_latent.dat"),resultsL)
    writedlm(string("Data1/result","$(P.Prob_transmission)","_symp.dat"),resultsS)
    writedlm(string("Data1/result","$(P.Prob_transmission)","_asymp.dat"),resultsA)

end

@everywhere P=InfluenzaParameters(

    precaution_factorS = 0.0,
    precaution_factorV = 0.0,
    VaccineEfficacy = 0.0,
    GeneralCoverage = 0.0,
    Prob_transmission = 0.08,
    sim_time = 365

)

run_main(P,1000)

