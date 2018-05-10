using DataArrays, DataFrames
using Match
using ParallelDataTransfer
using QuadGK
using Parameters #module
using Distributions
using StatsBase
using Base.Profile
include("parameters.jl")
include("PopStruct.jl")
include("functions.jl")


sigma1 = 0.4
for ef1 = 0.2:0.1:0.8
    ef1 = 0.4
P=InfluenzaParameters(
    precaution_factorS = sigma1,
    precaution_factorV = 0.0,
    VaccineEfficacy = ef1,
    GeneralCoverage = 1,
    Prob_transmission = 0.079,
    sim_time = 365,
    grid_size_human = 10000
)


humans = Array{Human}(P.grid_size_human)
    
setup_human(humans)
setup_demographic(humans,P)
vaccination(humans,P)

########################
f = open(string("VaccineEffectiveness/VaccineEffec","$ef1",".dat"),"w")
for j = 1:15

    A = find(x -> x.vaccinationStatus == 1 && x.contact_group == j,humans)

    soma = 0.0
    for k = A
        soma += humans[k].vaccineEfficacy

    end
    soma = soma/length(A) 
    println(f,"$j $soma")
end
close(f)
end

#################
######erasing the age groups


if rand()<0.5
println("ok")
end


for i=1:P.grid_size_human
    humans[i].contact_group = 1
end

function test_humanage()
    ag = map(x -> x.age, humans)
    plot(x = ag, Geom.histogram)

    a = find(x -> x.gender == FEMALE, humans)
    ag = zeros(Int64, length(a))
    for i=1:length(a)
        ag[i] = humans[a[i]].agegroup
    end

    ag = map(x -> x.agegroup, humans)

#    ag = map(x -> x.age, humans)
    plot(x = ag, Geom.histogram)

    find(x -> x.age >= 15, humans)
    find(x -> x.age >= 15 && x.gender == MALE, humans)
    find(x -> x.age >= 15 && x.gender == FEMALE, humans)
    
end


d = LogNormal(1,sqrt(0.4356))
d1 = Vector{Float64}(3000)
for i = 1:length(d1)
d1[i] = min(15,rand(d))

end

writedlm("testeLogNormal.dat",d1)

X = Matrix{Float64}(15,15)
X[1,:] = ContactMatrix[1,:]
for i = 2:15
    for j = 1:15
        X[i,j] = ContactMatrix[i,j]-ContactMatrix[i-1,j]

    end

end
writedlm("MatrixContact2.dat",X)
function test_getagegroup(humans)
    # get an array of the age groups in humans
    ContactMatrix = ContactMatrixFunc()
    a = map(x -> finding_contact(humans,x,ContactMatrix), 1:P.grid_size_human )
    l = length(find(x -> x == 0 || x==-1, a))
    if l == 0 
        print("get_age_group function is good")
    else 
        print("get_age_group function is good")
    end

    #compare the same code to below
    #for i=1:length(human)
    #    if(get_age_group(human[i].age) == 0)
    #        print(i)
    #    end
    #end 
end


NB = N_Binomial()
    ContactMatrix = ContactMatrixFunc()
    ContactMatrix2 = ContactMatrixFunc2()
    for i=1:P.grid_size_human
        humans[i].daily_contacts = rand(NB[humans[i].contact_group])
    end

 @profile finding_contact(humans,1,ContactMatrix)

## to do
## if there is a protection level, the
function myfunc()
    A = rand(200, 200, 400)
    maximum(A)
end 

#############################################################

FrIndex = Matrix{Float64}(length(humans),2)
for i = 1:length(humans)
rd = rand()
MaxFra,MinFra = FrailtyIndex(humans[i])
FrIndex[i,2] = rd*(MaxFra-MinFra)+MinFra
FrIndex[i,1] = humans[i].age
end

writedlm("Frailty.dat",FrIndex)

for i = 1:length(humans)
    FrIndex[i,2] = humans[i].vaccineEfficacy
    FrIndex[i,1] = humans[i].age
end


writedlm("VaccineEffic.dat",FrIndex)

for i = 1:length(humans)
    FrIndex[i,2] = humans[i].Coverage
    FrIndex[i,1] = humans[i].age
end


writedlm("VaccineCov.dat",FrIndex)

find(x -> x.age <= 64 && x.age >= 50, humans)

find(x -> x.age <= 64 && x.age >= 50 && x.vaccinationStatus == 1, humans)
 
###############################################################33
#########################

d = LogNormal(1,sqrt(0.4356))
d1 = Vector{Float64}(3000)
for i = 1:length(d1)
d1[i] = rand(d)
end
mean(d1)

Size = Vector{Int64}(15)

TesteM = zeros(Int64,15,15)
TesteM2 = zeros(Float64,15,15)

for i = 1:2000
    print("$i")
    finding_contact3(humans,j,ContactMatrix)
end

for i = 1:15
    Tam = find(x -> x.contact_group == i,humans)
    Size[i] = length(Tam)
end

for i = 1:15
    for j = 1:15
        TesteM2[i,j] = TesteM[i,j]/Size[i]/2000
    end
end
i = 1
j = 1


writedlm("TestContactMatrix.dat",TesteM2)

@time contact_dynamic3(humans,P)
@time contact_dynamic2(humans,P)

@time finding_contact2(humans,i,ContactMatrix)
@time finding_contact3(humans,i,ContactMatrix2)


