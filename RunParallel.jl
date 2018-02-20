addprocs(2)
println("added $(nworkers()) processors")
info("starting @everywhere include process...")
@everywhere include("basicModel.jl")
################## To run this files, You must check the return of BasicModel.jl
#######################3


function run_main(P::InfluenzaParameters,numberofsims::Int64)
    results = pmap(x->main(x,P),1:numberofsims,distributed = true)
    dataprocess(results,P)
end

function dataprocess(results,P::InfluenzaParameters)

        writedlm(string("Data/result","$(P.precaution_factor)","-3.dat"),results)

end
@everywhere sigma = 0.0
@everywhere ef = 0.0
@everywhere P=InfluenzaParameters(
    precaution_factor = sigma,
    VaccineEfficacy = ef,
    GeneralCoverage = 0.2,
    Prob_transmission = 0.0072,
    sim_time = 365
)

run_main(P,1000)

