addprocs(4)
println("added $(nworkers()) processors")
info("starting @everywhere include process...")
@everywhere include("basicModelVar.jl")
################## To run this files, You must check the return of BasicModel.jl
#######################

function run_main(P::InfluenzaParameters,numberofsims::Int64)
    
    results=pmap(x->main(x,P),1:numberofsims,distributed = true)###parallel Programing
    #dataprocess(results,P)
    s = sum(sum(results))/numberofsims #mean for the total number of infected individual
    return s
end

function dataprocess(results,P::InfluenzaParameters)

        writedlm(string("Data/Results/result","$(P.precaution_factor)","Model","$(P.GeneralCoverage)","-3.dat"),results)

end

###########for sigmaS = 0.2
 sigmaS = 0.2
    for ef1=0.2:0.3:0.8
        f = open(string("Data3/varying_sS","$(sigmaS)","_Ef","$(ef1)",".dat"), "w")
        println("$sigmaS $ef1")
        for sigmaV=0.0:0.02:0.2
                for Cov1=0.1:0.1:0.9
                
                   # println("$sigmaV $Cov1")

                    P=InfluenzaParameters(
                        sim_time = 365,
                        Prob_transmission = 0.08,
                        GeneralCoverage = Cov1,
                        precaution_factorV = sigmaV,
                        VaccineEfficacy = ef1,
                        precaution_factorS = sigmaS
    
                    )
                    
                    total = run_main(P,1000)
                    println(f,"$sigmaV $Cov1 $total")
                end
            end
        close(f)
    end


###########for sigmaS = 0.5
 sigmaS = 0.5
 for ef1=0.2:0.3:0.8
        println("$sigmaS $ef1")
        f = open(string("Data3/varying_sS","$(sigmaS)","_Ef","$(ef1)",".dat"), "w")

        for sigmaV=0.0:0.05:0.5
            for Cov1=0.1:0.1:0.9
                
                    #println("$sigma1 $ef1")

                    P=InfluenzaParameters(
                        sim_time = 365,
                        Prob_transmission = 0.0336,
                        GeneralCoverage = Cov1,
                        precaution_factorV = sigmaV,
                        VaccineEfficacy = ef1,
                        precaution_factorS = sigmaS
    
                    )
                    
                total = run_main(P,1000)
                println(f,"$sigmaV $Cov1 $total")
            end
        end
        close(f)
 end

###########for sigmaS = 0.8
sigmaS = 0.8
for ef1=0.2:0.3:0.8
    println("$sigmaS $ef1")
    f = open(string("Data3/varying_sS","$(sigmaS)","_Ef","$(ef1)",".dat"), "w")

    for sigmaV=0.0:0.1:0.8
            for Cov1=0.1:0.1:0.9
            
                #println("$sigma1 $ef1")

                P=InfluenzaParameters(
                    sim_time = 365,
                    Prob_transmission = 0.0336,
                    GeneralCoverage = Cov1,
                    precaution_factorV = sigmaV,
                    VaccineEfficacy = ef1,
                    precaution_factorS = sigmaS

                )
                
                total = run_main(P,1000)
                println(f,"$sigmaV $Cov1 $total")
            end
        end
    close(f)
end


