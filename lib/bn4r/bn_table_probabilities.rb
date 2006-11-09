##############################################################
#
#  Methods for poulating Bayes Net Probabilities tables.
#  
#  Author: Sergio Espeja ( http://www.upf.edu/pdi/iula/sergio.espeja, sergio.espeja at gmail.com )
#  
#  Developed in: IULA ( http://www.iula.upf.es )
#  
##############################################################


# Bayes Net Table Probabilities Generator
class BnTableProbabilitiesGenerator
  def get_node_probability_from_boolean_combination(boolean_combination)
    0.0
  end  
end

# Bayes Net Table Probabilities Generator from Positive Negative Relations
class BNTPGFromPositiveNegativeRelations < BnTableProbabilitiesGenerator

  public
  # type_of_position_impact is a array of boolean values showing the 
  # relation ( positive | negative ) beetwen the node and its parents.
  def table_probabilities_for_node(node, type_of_position_impact)
    raise "Node parents and type_of_position_impact with different size" if node.parents.size != type_of_position_impact.size
    boolean_combinations = []
    (2**node.parents.size).times { |i|
      boolean_combination = Array.new(node.parents.size, false)
      actual_value = i
      (node.parents.size).times { |j|
        boolean_combination[j] = !(actual_value%2 == 0)
        actual_value = actual_value / 2
      }
      boolean_combinations << boolean_combination
    }
    #p boolean_combinations
    table_probabilities = [] # Array.new(2**(node.parents.size+1))
    boolean_combinations.each { |boolean_combination|
      [true,false].each { |node_value|
        prob = BNTPGFromPositiveNegativeRelations.get_node_probability_from_boolean_combination(boolean_combination, type_of_position_impact)
        prob = 1 - prob if node_value == false
        table_probabilities[node.get_table_index(node_value, boolean_combination)] = prob
        #p "pos :" + node.get_table_index(node_value, boolean_combination).to_s
        #p "Ok :" + node.get_table_index(node_value, boolean_combination).to_s if node.get_table_index(node_value, boolean_combination) > 2**node.parents.size
      }
    }
   #p table_probabilities
   table_probabilities
  end

  # returns P(node=yes| parents={boolean_combination}) where parents have
  # relations with the node showed in type_of_position_impact
  # type_of_position_impact is a array of boolean values showing the 
  # relation ( positive | negative ) beetwen the node and its parents.
  def self.get_node_probability_from_boolean_combination(boolean_combination, type_of_position_impact)
    num_eq = 0.0
    boolean_combination.size.times { |i|
      num_eq += 1.0 if type_of_position_impact[i] && boolean_combination[i]
      num_eq += 1.0 if !type_of_position_impact[i] && !boolean_combination[i]
    }
    num_eq / boolean_combination.size.to_f
  end
end

def generate_boolean_combinations(num)
    boolean_combinations = []
    (2**num).times { |i|
      boolean_combination = Array.new(num, false)
      actual_value = i
      (num).times { |j|
        boolean_combination[j] = !(actual_value%2 == 1)
        actual_value = actual_value / 2
      }
      boolean_combinations << boolean_combination.reverse
    }
  boolean_combinations
end

