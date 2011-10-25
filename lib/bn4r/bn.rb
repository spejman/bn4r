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
require 'rgl/traversal'

include RGL

class BayesNet < DirectedAdjacencyGraph

#  DirectedAdjacencyGraph redefined methods
#  ---------------------------------------- 

# Adds a directed edge between parent and child BayesNetNodes labeled
# with tag ( if tag is included, othewise the label is nil ).
  def add_edge(parent, child, tag=nil)
    raise "Nodes must be of the class BayesNetNodes" if parent.class != BayesNetNode or child.class != BayesNetNode
    raise "Self relations not allowed in BayesNet" if parent == child
    raise "Diferent BayesNetNodes with equal name: " + parent.name if parent.name == child.name
    
    edge = super(parent, child)
    child.parents << parent unless child.parents.include? parent
    child.relations << tag if !tag.nil?
    edge
  end

  # Removes a vertex and its edges of the BayesNet, removing
  # also its references from childs nodes.
  def remove_vertex(v)
    self.each_child(v) {|c| c.parents.delete(v)}
    super(v)
  end

# Adds a vertex to the BayesNet
#  def add_vertex(node)
#    raise "BayesNet nodes must be of BayesNetNode class" if node.class != BayesNetNode
#    raise "Already exists a node with name #{node.name}" unless get_variable(node.name).nil?
#    super(node)
#  end

# BN Methods
# ----------

  # Returns an array with childs of given node ( or vertice )
  def childs(v)
    begin
      self.adjacent_vertices(v)
    rescue RGL::NoVertexError
      []
    end
  end

  # Iterates all the childs of given node ( or vertice )
  def each_child(v, &block)
    childs(v).each(&block)
  end

  # Clears the value of all BayesNetNodes in Bayes Net.
  def clear_values!
      vertices.each { |v| v.clear_value }
  end

  # Gets the variable with given name.
  def get_variable( text )
    vertices.find { |v| v.name == text }
  end

  # Returns the root nodes of the Bayes Net.
  def roots
    vertices.select { |v| root?(v) }
  end

  # Returns the leaf nodes
  def leafs
    vertices.select { |v| childs(v).size == 0 }
  end

  # Iterates all the leaf nodes ( or vertices )
  def each_leaf(&block)
    leafs.each(&block)
  end
  
  def siblings(v)
    return roots if v.root?
    v.parents.map do |p|
      childs(p)
    end.flatten.uniq
  end


  # Returns true/false if given Node is root.
  def root?(v)
    num_parents(v) == 0
  end

  # Returns the number of parents of a node.
  def num_parents(v)
    v.parents.size
  end

  # Returns de deep of the bayes net (larger path from a root node 
  # to a child node).
  def deep # TODO depth?
    vertices.collect {|root| root.deep }.max
  end
  # Return the probability of a distribution in the bayes net
  # all nodes in the Bayes Net must have a value, otherwise
  # will raise a exception  
  def inference_by_enumeration # inject!
    vertices.inject(1) do |memo, v|
      memo * p_v_cond_parents(v)
    end
  end

  # Returns the probability of a node conditioned to his parents:
  #   P(v|parents(v))
  def p_v_cond_parents(v)
    givens_assignments = v.parents.collect {|parents| parents.value}
    v.get_probability(v.value, givens_assignments).to_f
  end
  
  # Returns true if all nodes have values.
  def all_nodes_with_values?
    vertices.none? {|v| v.value.nil? }
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

  # Returns nodes ordered by Breadth First Search
  def nodes_ordered_by_breadth_first_search(nodes = roots, bn_ordered = Array.new)
    nodes.each { |v| 
      next if bn_ordered.include?(v)
      bn_ordered << v
      nodes_ordered_by_breadth_first_search(childs(v), bn_ordered)
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

  # Renames a node
  def rename(new_name)
    @name = new_name  
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
    @givens
  end

  # Return node relations
  def relations
    @relations
  end

  # Return the number of parents
  def num_parents
    parents.size
  end
  
  # Returns de deep of the node ( larger path to root nodes )
  def deep(node=self) # depth?
    if node.root? 
      1 
    else
      node.parents.map{|p| p.deep }.max + 1
    end
  end
  
  # Returns true if the node is a root node ( doesn't have parents ).
  def root?
    num_parents == 0
  end

  # Returns true if all parents of the node in the bn have values
  def all_parents_with_values?
    parents.none? {|v| v.value.nil? }
  end

  def to_s
    name + (value.nil? ? "" : (" = " + value.to_s))
  end

  # If givens don't exist, it adds them
  # 
  # if givens is nil, then internal givens is assumed
  # table must have probability values in order like BAD!!!
  # [g0=pos0 & g1=pos0 & ... & node_value=pos0, ..., g0=pos0 & g1=pos0 & ... & node_value=posN,
  # 
  def set_probability_table (givens, table)
    # perhaps we should do some error checking on the table entries here?
    @table_is_a_proc = (table.class != Array)
    @givens = givens unless givens.nil?
    
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
    @givens.inject(@outcomes.size){ |mem, g| mem * g.outcomes.size }
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
    return @table[get_table_index(node_assignment, givens_assignments)] if @table_is_a_proc.nil? || !@table_is_a_proc
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
  end

  
end
