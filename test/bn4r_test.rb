require File.dirname(__FILE__) + '/test_helper.rb'
require 'bn_test_models'

class Bn4rTest < Test::Unit::TestCase


  def setup
  end
 
# TESTS
 
  def test_siblings
    bn_aima = bayes_net_aima
    b = bn_aima.get_variable("Burglary")
    a = bn_aima.get_variable("Alarm")
    j = bn_aima.get_variable("JohnCalls")
    m = bn_aima.get_variable("MaryCalls")

    b_siblings = bn_aima.siblings(b)
    a_siblings = bn_aima.siblings(a)
    j_siblings = bn_aima.siblings(j)
    m_siblings = bn_aima.siblings(j)


    
    assert j_siblings.include?(j)
    assert j_siblings.include?(m)
    assert m_siblings.include?(j)
    assert m_siblings.include?(m)
    
    assert_equal j_siblings.size, 2
    assert_equal m_siblings.size, 2
    assert_equal a_siblings.size, 1
    assert_equal b_siblings.size, 2
    
  end
 
  def test_childs
    bn_aima = bayes_net_aima
    b = bn_aima.get_variable("Burglary")
    a = bn_aima.get_variable("Alarm")
    j = bn_aima.get_variable("JohnCalls")
    m = bn_aima.get_variable("MaryCalls")
    
    a_childs = bn_aima.childs(a)
    
    assert_equal a_childs.size, 2
    assert a_childs.include?(j)
    assert a_childs.include?(m)
    
    assert_equal bn_aima.childs(j).size, 0

  end
 
  def test_leafs
  
    bn_aima = bayes_net_aima
    j = bn_aima.get_variable("JohnCalls")
    m = bn_aima.get_variable("MaryCalls")

    leafs = bn_aima.leafs
    assert_equal leafs.size, 2
    assert leafs.include?(j)
    assert leafs.include?(m)
    
  end
 
  def test_create_sample_bn
    bn = bayes_net_aaile
  
    assert_equal bn.vertices.size, 5
    assert_equal bn.edges.size, 4
  end
  
  def test_deep
    bn_aima = bayes_net_aima
    b = bn_aima.get_variable("Burglary")
    a = bn_aima.get_variable("Alarm")
    j = bn_aima.get_variable("JohnCalls")
    m = bn_aima.get_variable("MaryCalls")

    assert_equal 1, b.deep
    assert_equal 2, a.deep
    assert_equal 3, j.deep
    assert_equal 3, m.deep
    
    assert_equal 3, bn_aima.deep
    
    bn = bayes_net_aima2
    rain = bn.get_variable("Rain").copy
    sprinkler = bn.get_variable("Sprinkler").copy
    wetgrass = bn.get_variable("WetGrass").copy
    cloudy = bn.get_variable("Cloudy").copy
    
    assert_equal 1, cloudy.deep
    assert_equal 2, rain.deep
    assert_equal 2, sprinkler.deep
    assert_equal 3, wetgrass.deep
    assert_equal 3, bn.deep
    
    
  end
  
  def test_nodes_ordered_by_breath_first_search

    bn_aima = bayes_net_aima
    b = bn_aima.get_variable("Burglary")
    e = bn_aima.get_variable("Earthquake")
    a = bn_aima.get_variable("Alarm")
    j = bn_aima.get_variable("JohnCalls")
    m = bn_aima.get_variable("MaryCalls")

    bn_ordered = bn_aima.nodes_ordered_by_breath_first_search([b,e])
    
    assert_equal bn_ordered.size, 5
    assert_equal bn_ordered[0].name, b.name
    assert_equal bn_ordered[1].name, a.name
    assert [bn_ordered[2].name, bn_ordered[3].name].include?(j.name)
    assert [bn_ordered[2].name, bn_ordered[3].name].include?(m.name)
    assert_equal bn_ordered[4].name, e.name

  end
  
  def test_graph_viz
    bn = bayes_net_aaile
    # print "\n\n" + bn.to_dot_graph.to_s
    
    assert bn.to_dot_graph.to_s.size > 0, "bn.to_dot_graph gives no output."
  end
  
  def test_probability_assingment
    bn_aima = bayes_net_aima
    b = bn_aima.get_variable("Burglary")
    a = bn_aima.get_variable("Alarm")
    j = bn_aima.get_variable("JohnCalls")
    m = bn_aima.get_variable("MaryCalls")
    
    assert_equal b.get_probability(true, []), 0.001
    assert_equal b.get_probability(false, []), 0.999
    assert_equal b.get_probability(false, []), 0.999
    
    assert_equal a.get_probability(true, [false,false]), 0.001
    assert_equal a.get_probability(true, [true,false]), 0.94
    assert_equal a.get_probability(false, [true,true]), 0.05
    
    assert_equal j.get_probability(true, [true]), 0.90
    assert_equal m.get_probability(true, [false]), 0.01
    
  end
  
  def test_CPT_size
    bn_aima = bayes_net_aima
    b = bn_aima.get_variable("Burglary")
    a = bn_aima.get_variable("Alarm")
    j = bn_aima.get_variable("JohnCalls")
    m = bn_aima.get_variable("MaryCalls")

    assert_equal b.get_table_size, 2
    assert_equal a.get_table_size, 8
    assert_equal j.get_table_size, 4
    assert_equal m.get_table_size, 4
  end
  
  def test_base_methods
    bn_aima = bayes_net_aima
    b = bn_aima.get_variable("Burglary")
    a = bn_aima.get_variable("Alarm")
    assert bn_aima.root?(b)
    assert !bn_aima.root?(a)
    
  end
  
  def test_inference_by_enumeration
    bn_aima = bayes_net_aima
    b = bn_aima.get_variable("Burglary")
    e = bn_aima.get_variable("Earthquake")
    a = bn_aima.get_variable("Alarm")
    j = bn_aima.get_variable("JohnCalls")
    m = bn_aima.get_variable("MaryCalls")

    assert_equal bn_aima.vertices.size, 5
    assert_equal bn_aima.edges.size, 4
    
    assert !bn_aima.all_nodes_with_values?
    b.set_value(false); assert !bn_aima.all_nodes_with_values?
    e.set_value(false); assert !bn_aima.all_nodes_with_values?
    a.set_value(true); assert !bn_aima.all_nodes_with_values?
    j.set_value(true); assert !bn_aima.all_nodes_with_values?
    m.set_value(true)

    assert bn_aima.all_nodes_with_values?
        
    value = bn_aima.inference_by_enumeration
    assert_in_delta 0.0006281112, value, 10**(-10)
    
    bn_aima.clear_values!
    assert !bn_aima.all_nodes_with_values?
    
  end
  
  def test_inference_by_enumeration_ask
    bn_aima = bayes_net_aima
    b = bn_aima.get_variable("Burglary")
    e = bn_aima.get_variable("Earthquake")
    a = bn_aima.get_variable("Alarm")
    j = bn_aima.get_variable("JohnCalls")
    m = bn_aima.get_variable("MaryCalls")    
    j.set_value(true)  
    m.set_value(true)
    
    assert_equal bn_aima.vertices.size, 5
    assert_equal bn_aima.edges.size, 4
    value1 = bn_aima.enumeration_ask(b,[j,m])
    value2 = bn_aima.enumeration_ask(b,[j,m], [j,m,a,b,e])
    value3 = bn_aima.enumeration_ask(b,[j,m], [b,e,a,j,m])
    assert_equal value1[0], value2[0]
    assert_equal value1[0].to_f, value3[0].to_f
    assert_in_delta value1[1].to_f, value2[1].to_f, 10**(-10)
    assert_equal value1[1], value3[1]
    assert_in_delta 0.000592242, bn_aima.enumeration_ask(b,[j,m])[0], 10**(-9)
    bn_aima.clear_values!
    assert !bn_aima.all_nodes_with_values?

  end
  
  
  def test_table_probabilities_for_node
    bn_aima = bayes_net_aima
    b = bn_aima.get_variable("Burglary")
    e = bn_aima.get_variable("Earthquake")
    a = bn_aima.get_variable("Alarm")
    BNTPGFromPositiveNegativeRelations.new.table_probabilities_for_node(a, [true,true])

#    BNTPGFromPositiveNegativeRelations.new.populate_bn_with_tags(bn_aima)
    assert true
  end

  def test_prior_sampling

    bn = bayes_net_aima2

    hash = Hash.new(0)
    nodes_ordered = bn.nodes_ordered_by_dependencies
    10000.times { hash[ bn.prior_sample(nodes_ordered).collect {|v| v.value} ] += 1 }
    
    combination_of_prob = nodes_ordered.collect { |v|
      case v.name
        when "Cloudy"
          true
        when "Sprinkler"
          false
        when "Rain"
          true
        when "WetGrass"
          true
        else
          raise "Incorrect BayesNet created at bayes_net_aima2"
      end
    }
    
    prob = hash[combination_of_prob].to_f/10000.0

    assert_in_delta 0.3, prob, 0.1, "Its inprobable but possible that this error occurs, \
                                      because we are working with statistics and random data, \
                                      try again and if still occurs take care of it."
     
  end

  def test_rejection_sampling
    bn = bayes_net_aima2

    rain = bn.get_variable("Rain").copy
    sprinkler = bn.get_variable("Sprinkler").copy

    rain.set_value(true)
    sprinkler.set_value(true)
    
    results = bn.rejection_sampling(rain, sprinkler, 1000)

    str_error = " Its improbable but possible that this error occurs, \
                  because we are working with statistics and random data, \
                  try again and if still occurs take care of it."
    assert ((results[0] > 0.2) and (results[0] < 0.4)), "Results aren't in interval [0.2,0.4] --> " + results[0].to_s + str_error
    assert ((results[1] > 0.6) and (results[1] < 0.8)), "Results aren't in interval [0.6,0.8] --> " + results[1].to_s + str_error
  end

  def test_likelihood_weighting
    bn = bayes_net_aima2

    rain = bn.get_variable("Rain").copy
    sprinkler = bn.get_variable("Sprinkler").copy

    rain.set_value(true)
    sprinkler.set_value(true)
    
    results = bn.likelihood_weighting(rain, sprinkler, 100)

    str_error = " Its improbable but possible that this error occurs, \
                  because we are working with statistics and random data, \
                  try again and if still occurs take care of it."
    assert ((results[0] > 0.2) and (results[0] < 0.4)), "Results aren't in interval [0.2,0.4] --> " + results[0].to_s + str_error
    assert ((results[1] > 0.6) and (results[1] < 0.8)), "Results aren't in interval [0.6,0.8] --> " + results[1].to_s + str_error
  end


end
