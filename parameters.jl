@enum HEALTH SUSC = 1 INF = 2 REC = 3 UNDEF = 0

@with_kw type InfluenzaParameters @deftype Int64

    sim_time = 30
    grid_size_human = 1000
    initial_infected = 1

    ProbAsympMin::Float64 = 0.04
    ProbSympMax::Float64 = 0.28
    reduction_factor::Float64 = 0.8

    Prob_transmission::Float64 = 0.1
    InfectionTimeMax = 10
    InfectionTimeMin = 7
    
    precaution_factor::Float64 = 0.0

    NumberOfContactsMin = 10
    NumberOfContactsMax = 30

    GeneralCoverage::Float64 = 0.1
    VaccineEfficacy::Float64 = 0.2

    Model = 2
end

