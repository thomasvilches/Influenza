include("SlurmConnect.jl")

using ProgressMeter
using PmapProgressMeter
using Parameters
using DataArrays,DataFrames
using QuadGK
using Distributions
using StatsBase
using ParallelDataTransfer
using Match
using Lumberjack
using FileIO
using SlurmConnect 

add_truck(LumberjackTruck("processrun.log"), "my-file-logger")
remove_truck("console")
info("lumberjack process started up, starting repl")

info("adding procs...")

s = SlurmManager(512)
@eval Base.Distributed import Base.warn_once
addprocs(s, partition="defq", N=16)

println("added $(nworkers()) processors")
info("starting @everywhere include process...")

@everywhere include("basicModelSlurm.jl")
################## To run this files, You must check the return of BasicModel.jl
#######################3


function dataprocess(results,P::InfluenzaParameters,numberofsims)

    resultsL = Matrix{Int64}(P.sim_time,numberofsims)
    resultsA = Matrix{Int64}(P.sim_time,numberofsims)
    resultsS = Matrix{Int64}(P.sim_time,numberofsims)
    resultsR0 = Vector{Int64}(numberofsims)
    resultsSymp = Vector{Int64}(numberofsims)
    resultsAsymp = Vector{Int64}(numberofsims)
    resultsNumAge = Matrix{Int64}(15,numberofsims)
    resultsFailVector = Matrix{Int64}(15,numberofsims)

    Infection_Matrix = zeros(Int64,15,15)
    Fail_Matrix = zeros(Int64,15,15)
    Infection_Matrix_average = zeros(Float64,15,15)
    Contact_Matrix_General = zeros(Float64,15,15)
    for i=1:numberofsims
        resultsL[:,i] = results[i][1]
        resultsS[:,i] = results[i][2]
        resultsA[:,i] = results[i][3]
        resultsR0[i] = results[i][4]
        resultsSymp[i] = results[i][5]
        resultsAsymp[i] = results[i][6]

        Infection_Matrix = Infection_Matrix + results[i][7]
        Fail_Matrix =  Fail_Matrix + results[i][8]
        Contact_Matrix_General = Contact_Matrix_General + results[i][9]
        resultsNumAge[:,i] = results[i][10]
        resultsFailVector[:,i] = results[i][11]


    end
    Infection_Matrix = Infection_Matrix/numberofsims
    Fail_Matrix =  Fail_Matrix/numberofsims
    Contact_Matrix_General = Contact_Matrix_General/numberofsims
    
    directory = "March27/"

    writedlm(string("$directory","result","$(P.Prob_transmission)","Ef","$(P.VaccineEfficacy)","PS","$(P.precaution_factorS)","PV","$(P.precaution_factorV)","_latent.dat"),resultsL)
    writedlm(string("$directory","result","$(P.Prob_transmission)","Ef","$(P.VaccineEfficacy)","PS","$(P.precaution_factorS)","PV","$(P.precaution_factorV)","_symp.dat"),resultsS)
    writedlm(string("$directory","result","$(P.Prob_transmission)","Ef","$(P.VaccineEfficacy)","PS","$(P.precaution_factorS)","PV","$(P.precaution_factorV)","_asymp.dat"),resultsA)
    writedlm(string("$directory","result","$(P.Prob_transmission)","Ef","$(P.VaccineEfficacy)","PS","$(P.precaution_factorS)","PV","$(P.precaution_factorV)","_R0.dat"),resultsR0)
    writedlm(string("$directory","result","$(P.Prob_transmission)","Ef","$(P.VaccineEfficacy)","PS","$(P.precaution_factorS)","PV","$(P.precaution_factorV)","_SympInf.dat"),resultsSymp)
    writedlm(string("$directory","result","$(P.Prob_transmission)","Ef","$(P.VaccineEfficacy)","PS","$(P.precaution_factorS)","PV","$(P.precaution_factorV)","_AsympInf.dat"),resultsAsymp)
    writedlm(string("$directory","result","$(P.Prob_transmission)","Ef","$(P.VaccineEfficacy)","PS","$(P.precaution_factorS)","PV","$(P.precaution_factorV)","_InfMatrix.dat"),Infection_Matrix)
    writedlm(string("$directory","result","$(P.Prob_transmission)","Ef","$(P.VaccineEfficacy)","PS","$(P.precaution_factorS)","PV","$(P.precaution_factorV)","_FailMatrix.dat"),Fail_Matrix)
    writedlm(string("$directory","result","$(P.Prob_transmission)","Ef","$(P.VaccineEfficacy)","PS","$(P.precaution_factorS)","PV","$(P.precaution_factorV)","_ContactMatrixGeneral.dat"),Contact_Matrix_General)
    writedlm(string("$directory","result","$(P.Prob_transmission)","Ef","$(P.VaccineEfficacy)","PS","$(P.precaution_factorS)","PV","$(P.precaution_factorV)","_NumAgeGroup.dat"),resultsNumAge)
    writedlm(string("$directory","result","$(P.Prob_transmission)","Ef","$(P.VaccineEfficacy)","PS","$(P.precaution_factorS)","PV","$(P.precaution_factorV)","_FailVector.dat"),resultsFailVector)
end
function run_main(P::InfluenzaParameters,numberofsims::Int64)
    
    results = pmap((cb, x) -> main(cb, x, P), Progress(numberofsims*P.sim_time), 1:numberofsims, passcallback=true)

    dataprocess(results,P,numberofsims)
end

for PV = 0.0:0.01:0.3
    for ef1 = 0.2:0.01:0.4
 P=InfluenzaParameters(

    precaution_factorS = 0.4,
    precaution_factorV = PV,
    VaccineEfficacy = ef1,
    GeneralCoverage = 1,
    Prob_transmission = 0.079,
    sim_time = 200,
    grid_size_human = 10000

)
run_main(P,5000)
    end
end


