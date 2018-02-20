addprocs(2)
println("added $(nworkers()) processors")
info("starting @everywhere include process...")
@everywhere include("basicModel.jl")
################## To run this files, You must check the return of BasicModel.jl
#######################3

function run_main(P::InfluenzaParameters,numberofsims::Int64)
    results=pmap(x->main(x,P),1:numberofsims,distributed = true)
    dataprocess(results,P)
    s = sum(results)/numberofsims
    return s
end

function dataprocess(results,P::InfluenzaParameters)

        writedlm(string("Data/Results/result","$(P.precaution_factor)","Model","$(P.VaccineEfficacy)","-3.dat"),results)

end

f = open("Data/varying.dat", "w")
 for sigma1=0.0:0.1:0.9
   for ef1=0.0:0.1:0.9
       @everywhere sigma = sigma1
       @everywhere ef = ef1#0.2
        println("$sigma1 $ef1")
        @everywhere P=InfluenzaParameters(
            sim_time = 365,
            precaution_factor = sigma,
            VaccineEfficacy = ef,
            Prob_transmission = 0.0072,
            GeneralCoverage = 0.2
        )
        
        total = run_main(P,1000)
        println(f,"$sigma1 $ef1 $total")
    end
end
close(f)

