include("basicModel.jl")
################## To run this files, You must check the return of BasicModel.jl
#######################3


function run_main(P::InfluenzaParameters,numberofsims::Int64)

    results = Matrix{Int64}(P.sim_time,numberofsims)
    forR0 = open(string("Data/R0check","$(P.Prob_transmission)",".dat"),"w")
    for i=1:numberofsims
        print("$i ")
        a,b = main(i,P)
        results[:,i] = a
        println(forR0,"$i $b")
    end
    close(forR0)
    dataprocess(results,P)
end

function dataprocess(results,P::InfluenzaParameters)

        writedlm(string("Data/result","$(P.precaution_factor)","-3.dat"),results)

end
sigma = 0.0
ef = 0.0
P=InfluenzaParameters(
    precaution_factor = sigma,
    VaccineEfficacy = ef,
    GeneralCoverage = 0.2,
    Prob_transmission = 0.0072,
    sim_time = 365
)

run_main(P,1000)

