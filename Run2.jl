include("basicModel.jl")
################## To run this files, You must check the return of BasicModel.jl
#######################3

function run_main(P::InfluenzaParameters,numberofsims::Int64)

    results = Matrix{Int64}(P.sim_time,numberofsims)

    for i=1:numberofsims
        #print("$i ")
        results[:,i] = main(i,P)
    end
    dataprocess(results,P)
    s = sum(results)/numberofsims
    return s
end

function dataprocess(results,P::InfluenzaParameters)

        writedlm(string("Data/Results/result","$(P.precaution_factor)","Model","$(P.VaccineEfficacy)","-3.dat"),results)

end

f = open("Data/varying2.dat", "w")
for sigma1=0.0:0.1:0.1
    for ef1=0.0:0.1:0.1
       
        println("$sigma1 $ef1")
        P=InfluenzaParameters(
            sim_time = 365,
            precaution_factor = sigma1,
            VaccineEfficacy = ef1,
            Prob_transmission = 0.0072,
            GeneralCoverage = 0.2
        )
        
        total = run_main(P,100)
        println(f,"$sigma1 $ef1 $total")
    end
end
close(f)

