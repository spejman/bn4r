  # Returns the BayesNet used as example in "Artificial Intelligence A 
  # Modern Approach, Rusell & Norvig, 2nd Ed." pp.494
  def bayes_net_aima
    # Create BayesNet
    bn_aima = BayesNet.new
    
    # Create nodes for the Bayes Net (BayesNetNodes)
    burglary = BayesNetNode.new("Burglary")
    earthquake = BayesNetNode.new("Earthquake")
    alarm = BayesNetNode.new("Alarm")
    john_calls = BayesNetNode.new("JohnCalls")
    mary_calls = BayesNetNode.new("MaryCalls")

    # Add nodes ( vertex ) to the BayesNet
    bn_aima.add_vertex(burglary)
    bn_aima.add_vertex(earthquake)
    bn_aima.add_vertex(alarm)
    bn_aima.add_vertex(john_calls)
    bn_aima.add_vertex(mary_calls)
    
    # Add relations ( edges ) between nodes in the BayesNet
    bn_aima.add_edge(burglary,alarm)
    bn_aima.add_edge(earthquake,alarm)
    bn_aima.add_edge(alarm,john_calls)
    bn_aima.add_edge(alarm,mary_calls)
    
    # Assign probabilities to each node
    burglary.set_probability_table([], [0.001, 0.999] )
    earthquake.set_probability_table([], [0.002, 0.998] )
    
    alarm.set_probability_table([burglary,earthquake], [0.95, 0.05, 0.94, 0.06, 0.29, 0.61, 0.001,0.999] )
    
    john_calls.set_probability_table([alarm], [0.90,0.10,0.05,0.95])
    mary_calls.set_probability_table([alarm], [0.70,0.30,0.01,0.99])
    
    bn_aima
  end

  # Returns the BayesNet used as example in "Artificial Intelligence A 
  # Modern Approach, Rusell & Norvig, 2nd Ed." pp.510
  def bayes_net_aima2
    bn_aima = BayesNet.new

    cloudy = BayesNetNode.new("Cloudy")
    sprinkler = BayesNetNode.new("Sprinkler")
    rain = BayesNetNode.new("Rain")
    wetgrass = BayesNetNode.new("WetGrass")

    bn_aima.add_vertex(cloudy)
    bn_aima.add_vertex(sprinkler)
    bn_aima.add_vertex(rain)
    bn_aima.add_vertex(wetgrass)
    
    bn_aima.add_edge(cloudy,sprinkler)
    bn_aima.add_edge(cloudy,rain)
    bn_aima.add_edge(sprinkler,wetgrass)
    bn_aima.add_edge(rain,wetgrass)
    
    cloudy.set_probability_table([], [0.5, 0.5] )

    sprinkler.set_probability_table([cloudy], [0.1, 0.9, 0.5, 0.5] )
    rain.set_probability_table([cloudy], [0.8, 0.2, 0.2, 0.8] )
    
    wetgrass.set_probability_table([sprinkler, rain], [0.99, 0.01, 0.9, 0.1, 0.9, 0.1, 0.0, 1.0] )
    bn_aima
  end

    def bayes_net_aaile
    bn = BayesNet.new
    rel = BayesNetNode.new("relational")
    q = BayesNetNode.new("qualificative")
    a = BayesNetNode.new("Adverbial")
    bn.add_vertex(rel)
    bn.add_vertex(q)
    bn.add_vertex(a)

#    ["preN", ...]    
    preN = BayesNetNode.new("preN")
    bn.add_vertex(preN)
    
    postN = BayesNetNode.new("postN")
    bn.add_vertex(postN)
    
 #   bn.add_edge("ser")
 #   bn.add_edge("G")
 #   bn.add_edge("prep")
    
    bn.add_edge(rel, preN)
    bn.add_edge(q, preN)
    bn.add_edge(a, preN)
    bn.add_edge(q, postN)
    
    bn
  end
  