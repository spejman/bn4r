##############################################################
#
#  Inference Algorithms for Bayesian Network Library for Ruby
#  
#  Author: Sergio Espeja ( http://www.upf.edu/pdi/iula/sergio.espeja, sergio.espeja at gmail.com )
#  
#  Developed in: IULA ( http://www.iula.upf.es ) and 
#  in bee.com.es ( http://bee.com.es )
#  
#  == Current implemented algorithms
#  * enumeration_ask
#  * prior_sample
#  * rejection_sampling
#  * likelihood_weighting
#
##############################################################
class BayesNet < DirectedAdjacencyGraph

# Inference Algorithms
  
  # ENUMERATION ASK algorithm
  # 
  # Implementation based on: S.Russell, P.Norving, "Artificial
  # Intelligence, A Modern Approach", 2nd Edition. pp 506
  # 
  # <b>x</b> --> query variable
  # 
  # <b>e</b> --> variables with observed values
  def enumeration_ask(x,e, bn_vertices = vertices)
    e << x
    q = []
    #p bn_vertices.collect { |v| v.name }
    x.outcomes.each {|outcome|
      x.set_value(outcome)
      q << enumerate_all(bn_vertices, e)
    }
    q
  end

  # Returns a sample from prior joint distribution specified by the network.
  # 
  # Implementation based on: S.Russell, P.Norving, "Artificial
  # Intelligence, A Modern Approach", 2nd Edition. pp 511-512
  # 
  # The input are the nodes of the bn ordered by dependencies see nodes_ordered_by_dependencies
  def prior_sample(nodes_ordered = nodes_ordered_by_dependencies)
    sample = Array.new
    nodes_ordered.each { |v| 
      value = rand < v.get_probability(true)
      v.set_value(value) 
      sample << v.copy
    }
    # leave the bn clear of values.
    nodes_ordered.each { |v| v.clear_value }

    return sample
  end

  # Returns an estimation of P(X=x|e) = <P(X=x|e), 1 - P(X=x|e)> obtained. Generates samples from prior joint 
  # distribution specified by the network, rejects all those that do not match the evidence,
  # and finally counts hoy often X = x occurs in remaining samples.
  # 
  # Caution, this algorthm is unusable for complex problems because rejects many samples!
  # 
  # Implementation based on: S.Russell, P.Norving, "Artificial
  # Intelligence, A Modern Approach", 2nd Edition. pp 513
  # 
  # <b>x</b> --> query variable
  # 
  # <b>e</b> --> variables with observed values
  # 
  # <b>n</b> --> Number of samples generated
  #  
  def rejection_sampling( x, e, n, bn = self )
  
      evidece_list = [e] if e.class != Array
      x_list = [x] if x.class != Array
           
      nodes_ordered = bn.nodes_ordered_by_dependencies
      evidence_vector = get_vector_value(evidece_list, nodes_ordered)
      x_vector = get_vector_value(x_list, nodes_ordered)
      
      total_valid = 0; total_correct = 0
      n.times do
        sample_vector  = bn.prior_sample(nodes_ordered).collect {|v| v.value}
        
        valid = true; correct = true
        for i in 0..(sample_vector.size-1) do
          correct = false if !x_vector[i].nil? and sample_vector[i] != x_vector[i]
          valid = false and break if !evidence_vector[i].nil? and sample_vector[i] != evidence_vector[i]
        end
        
        next if !valid
        total_valid += 1
        total_correct += 1 if correct  
      end
      
      p_true = total_correct.to_f/total_valid.to_f
      return [p_true, 1-p_true]
      #return [total_correct.to_f, total_valid.to_f]
  end
  
  # Returns an estimation of P(X=x|e) = <P(X=x|e), 1 - P(X=x|e)> obtained.
  # 
  # Implementation based on: S.Russell, P.Norving, "Artificial
  # Intelligence, A Modern Approach", 2nd Edition. pp 515
  # 
  # <b>x</b> --> query variable
  # 
  # <b>e</b> --> variables with observed values
  # 
  # <b>n</b> --> Number of samples generated
  #  
  def likelihood_weighting( x, e, n, bn = self )
  
    retval = [0.0, 0.0]
    n.times {
      w_sample, w = weighted_sample(e)
      value = w_sample.select { |v| v.name == x.name }[0].value
      #p value
      if value == x.value
        retval[1] += w
      else
        retval[0] += w
      end
    }
  
    norm = retval[1].to_f / (retval[0]+retval[1]).to_f

    return [norm, 1-norm]
  end

  protected
  # Auxiliar function to compute Enumeration Ask Algorithm
  def enumerate_all(vars, e)
  
    return 1.0 if vars.empty?
    
    y = vars.first; i = 1
    while !y.all_parents_with_values? and i < vars.size
      y = vars[i]
      i = i + 1
    end
    raise "Error bayes net not computable with enumeration-ask " + \
    "algorithm" if i == vars.size and !y.all_parents_with_values?
    
    if e.include?(y)
      return p_v_cond_parents(y) * enumerate_all(vars-[y], e)
    else
      prob = 0.0
      y.outcomes.each { |outcome|
        y.set_value(outcome)
        prob = prob + p_v_cond_parents(y) * enumerate_all(vars-[y], e+[y])
        y.clear_value
      }
      return prob
    end
  end

  # Returns an event and a weight.
  # 
  # Implementation based on: S.Russell, P.Norving, "Artificial
  # Intelligence, A Modern Approach", 2nd Edition. pp 515
  # 
  # <b>e</b> --> variables with observed values
  # 
  def weighted_sample(e, bn = self)
    
    nodes_ordered = bn.nodes_ordered_by_dependencies
    
    sample = Array.new
    w = 1.0
    nodes_ordered.each { |v| 
      node_actual = e.select { |node| node.name == v.name } if e.class == Array
      node_actual = [e] if e.class == BayesNetNode and e.name == v.name
      if !node_actual.nil? and node_actual.size == 1
        value = node_actual[0].value
        w = w * v.get_probability(value)
      else
        value = rand < v.get_probability(true)
      end
      v.set_value(value) 
      sample << v.copy
    }
    
    # leave the bn clear of values.
    bn.clear_values!
    return sample, w
  end

  # Axiliar function that returns an array of bn_vertices_ordered.size positions
  # with nil if position aren't in vertices_vector, and value if there's a match
  # in vertices_vector.
  def get_vector_value(vertices_vector, bn_vertices_ordered)
      bn_vertices_ordered.collect { |v|
        if !vertices_vector.nil?
          node_actual = vertices_vector.select { |node| node.name == v.name }
  
          case node_actual.size
            when 0
              nil
            when 1
              node_actual[0].value
            else
              raise "Error in get_vector_value" 
          end
        else
          nil
        end
      }  
  end

 

end