mutable struct Human
    health::HEALTH
    swap::HEALTH #do we need  this? We can do a sequential atualization
    timeinstate::Int64
    statetime::Int64
    vaccinationStatus::Int64
    vaccineEfficacy::Float64
    WhoInf::Int64
    Human() = new(SUSC,UNDEF,0,999,0,0.0,-1)
end


function setup_human(h::Array{Human})

    for i=1:length(h)
        h[i] = Human()
    end

end