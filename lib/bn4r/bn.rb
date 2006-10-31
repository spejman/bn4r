##############################################################
#
#  Bayesian Network Library for Ruby
#  
#  Author: Sergio Espeja ( http://www.upf.edu/pdi/iula/sergio.espeja, sergio.espeja at gmail.com )
#  
#  Developed in: IULA ( http://www.iula.upf.es ) and 
#  in bee.com.es ( http://bee.com.es )
#  
#  Based on work by Ryan Dahl in 
#  http://www.math.rochester.edu/people/grads/rld/bayesnets
#
##############################################################
require 'rgl/adjacency'
require 'rgl/dot'

include RGL

class BayesNet < DirectedAdjacencyGraph

#  DirectedAdjacencyGraph redefined methods
#  ---------------------------------------- 

# Adds a directed edge between parent and child BayesNetNodes labeled
# with tag ( if tag is included, othewise the label is nil ).
  def add_edge(parent, child, tag=nil)
    raise "Nodes must be of the class BayesNetNodes" if parent.class != BayesNetNode or child.class != BayesNetNode
    edge = super(parent, child)
    child.parents << parent
    child.relations << tag if !tag.nil?
    edge
  end

# BN Methods
# ----------

  # Clears the value of all BayesNetNodes in Bayes Net.
  def clear_values!
      vertices.each { |v| v.clear_value }
  end

  # Gets the variable with given name.
  def get_variable( text )
    vertices.each { |v| return v if v.name == text }
  end

  # Returns the root nodes of the Bayes Net.
  def roots
    vertices.select { |v| root?(v) }
  end

  # Returns true/false if given Node is root.
  def root?(v)
    return true if num_parents(v) == 0
    false
  end

  # Returns the number of parents of a node.
  def num_parents(v)
    return v.parents.size
  end

  # Return the probability of a distribution in the bayes net
  # all nodes in the Bayes Net must have a value, otherwise
  # will raise a exception  
  def inference_by_enumeration
    prob = 1.0;
    vertices.each {|v| prob = prob * p_v_cond_parents(v)}
    prob
  end

  # Returns the probability of a node conditioned to his parents:
  #   P(v|parents(v))
  def p_v_cond_parents(v)
    givens_assignments = v.parents.collect {|parents| parents.value}
    v.get_probability(v.value, givens_assignments).to_f
  end
  
  # Returns true if all nodes have values.
  def all_nodes_with_values?
    vertices.select {|v| !v.value.nil? }.size == vertices.size
  end

  # Returns nodes ordered by dependencies ( from those who haven't ( roots )
  # to leaves ).
  def nodes_ordered_by_dependencies(nodes = vertices, bn_ordered = Array.new)
    nodes.each { |v| 
      next if bn_ordered.include?(v)
      nodes_ordered_by_dependencies(v.parents, bn_ordered) if !v.root?
      bn_ordered << v 
     }
     return bn_ordered.flatten
  end

 
end

class BayesNetNode
  attr_reader :name, :outcomes, :extra_info, :value, :relations

  # create de BayesNetNode
  # name is the identifier of the node in the Bayesian Network
  # outcomes is an array with the posible values that this node 
  # can have, by default [true, false].
  # [optional] extra_info extra information that can be putted in the node
  def initialize ( name , outcomes = [true, false], extra_info = nil)
    @name = name
    @outcomes = outcomes
    @extra_info = extra_info
    @givens = []
    @relations = []
  end

  # Returns a copy of the node itself
  def copy
    tmp = BayesNetNode.new(@name, @outcomes, @extra_info)
    tmp.set_value(@value)
    tmp.set_probability_table(@givens, @table)
    tmp
  end

  def set_value(value)
    @value = value
  end

  def clear_value
    @value = nil
  end

  # Return node parents  
  def parents
    return @givens
  end

  # Return node relations
  def relations
    return @relations
  end

  # Return the number of parents
  def num_parents
    parents.size
  end
  
  # Returns true if the node is a root node ( doesn't have parents ).
  def root?
    return true if num_parents == 0
    false
  end

  # Returns true if all parents of the node in the bn have values
  def all_parents_with_values?
    parents.select {|v| !v.value.nil? }.size == parents.size
  end

  def to_s
    return name + (value.nil? ? "" : (" = " + value.to_s))
  end

  # if givens is nil, then internal givens is assumed
  # table must have probability values in order like BAD!!!
  # [g0=pos0 & g1=pos0 & ... & node_value=pos0, ..., g0=pos0 & g1=pos0 & ... & node_value=posN,
  # 
  def set_probability_table (givens, table)
    # perhaps we should do some error checking on the table entries here?
    @table_is_a_proc = (table.class != Array)
    @givens = givens if !givens.nil?
    
    raise "Error table incorrect number of positions (" \
      + table.size.to_s + " of " + self.get_table_size.to_s \
      + ")" if table.size != self.get_table_size

    @table = table
  end

  def parents_assignments
    parents.collect { |p| p.value }
  end

  # returns the number of cells that conditional probability table ( CPT )
  # haves.
  def get_table_size
    num = @outcomes.size
    @givens.each { |given| num = num * given.outcomes.size }
    return num
  end
  
  # Sets a probability to the node with a node_assignment conditioned to given_assignments
  #   P (node = node_assignment | givens = givens_assignments) = number
  def set_probability(number, node_assignment, givens_assignments)
    @table[get_table_index(node_assignment, givens_assignments)] = number
  end

  # Returns the probability of an assignment to a node conditioned to given_assignments
  #    P(node = node_assignment | givens = givens_assignments)
  # 
  # All givens_assigments must have value.
  def get_probability(node_assignment = value, givens_assignments = parents_assignments)
#    raise "Node must have a value and a givens_assignments, otherwise put" \
 #         + "them in function call" if node_assignment.nil? or givens_assignments.nil?
    # if there's a cached table take the index
    return @table[get_table_index(node_assignment, givens_assignments)] if @table_is_a_proc.nil? or !@table_is_a_proc
    # if the value is calculated on the fly using a function instead of
    # a table
    return @table[node_assignment, givens_assignments]
  end

  # Returns the corresponding index for the probability table given
  # <i>node_assignment</i> and <i>givens_assignments</i>
  def get_table_index(node_assignment, givens_assignments)
    x = []
    indices = []
    index = 0
    
    if givens_assignments.length != @givens.length
      raise "Error. Number of assignments does not match node."
    end
  
    if @givens.length > 0
      # create a indices array with the position of each value of
      # given assignments.
      givens_assignments.length.times { |i|
        assignment = givens_assignments[i]
        indices[i] = @givens[i].outcomes.index(assignment)
      }
  
      # create a array with the number of possible values each
      # given node and this node itself can have ( node.outcomes.length )
      # plus all next nodes.
      x[givens_assignments.length-1] = @outcomes.length
      (givens_assignments.length-2).downto(0) { |j|
        x[j] = x[j+1] * @givens[j+1].outcomes.length
      }      
  
      # to get the index, sum for each assignment the
      # product of each given assignment outcomes size
      # by its value index.
      givens_assignments.length.times { |i|
        index += x[i] * indices[i]
      }
    end
    
    index += @outcomes.index(node_assignment)
    
    return index
  end

  
end
