function setup_rand_initial_infected(h::Array{Human}, P::InfluenzaParameters)
    #for i=1:P.initial_infected
      randperson = rand(1:P.grid_size_human)
      
      make_human_infected(h[randperson], P)
    #end
    return randperson
end



function contact_dynamic(h::Array{Human},P::InfluenzaParameters)

    for i=1:P.grid_size_human
        if h[i].health==SUSC
            NumbContact = rand(P.NumberOfContactsMin:P.NumberOfContactsMax)

            for j=1:NumbContact
                r = rand(1:P.grid_size_human)
                if h[r].health == INF
                    if rand()>P.precaution_factor*(1-h[i].vaccinationStatus)
                        if rand()<= P.Prob_transmission*(1-P.VaccineEfficacy*h[i].vaccinationStatus)
                            h[i].swap = INF
                            h[i].WhoInf = r
                            break
                        end
                    end
                end
            end
        end
    end

end




function contact_dynamic2(h::Array{Human},P::InfluenzaParameters)

    for i=1:P.grid_size_human
        if h[i].health==SUSC
            numberInfected = 0
            NumbContact = rand(P.NumberOfContactsMin:P.NumberOfContactsMax)
            prob = 0
            for j=1:NumbContact
                r = rand(1:P.grid_size_human)
                if h[r].health == INF
                   numberInfected+=1 
                   
                end
            end
            
            prob = 1-(1-P.Prob_transmission*(1-P.precaution_factor*(1-h[i].vaccinationStatus))*(1-h[i].vaccinationStatus*h[i].vaccineEfficacy))^numberInfected
            if rand() < prob
                h[i].swap = INF
            end
        end
        
    end

end

function increase_timestate(h::Human,P::InfluenzaParameters)

    h.timeinstate+=1

    if h.timeinstate>h.statetime
        if h.health == INF
            h.swap = REC
        end
    end

end

function update_human(h::Array{Human},P::InfluenzaParameters)
    n1::Int64 = 0
    for i=1:P.grid_size_human
        if h[i].swap == INF
            make_human_infected(h[i],P)
            n1+=1
        elseif h[i].swap == REC
            make_human_recovered(h[i],P)
        end
    end
    return n1
end



function make_human_infected(h::Human, P::InfluenzaParameters)
    ## make the i'th human latent
  h.health = INF    # make the health ->inf
  h.swap = UNDEF
  h.statetime = rand(P.InfectionTimeMin:P.InfectionTimeMax)
  h.timeinstate = 0
end



function make_human_recovered(h::Human, P::InfluenzaParameters)
    ## make the i'th human latent
  h.health = REC    # make the health -> latent
  h.swap = UNDEF
  h.statetime = 999
  h.timeinstate = 0
end


function vaccination(h::Array{Human},P::InfluenzaParameters)

    if (P.GeneralCoverage) > 0

        for i=1:length(h)
            if rand()<P.GeneralCoverage
                h[i].vaccinationStatus = 1
                h[i].vaccineEfficacy = P.VaccineEfficacy
            end
        end
    end

end