##############################################################
#
#  Import fuctions of Bayesian Network Library for Ruby
#  
#  Author: Sergio Espeja ( http://www.upf.edu/pdi/iula/sergio.espeja, sergio.espeja at gmail.com )
#  
#  Developed in: IULA ( http://www.iula.upf.es ) and 
#  in bee.com.es ( http://bee.com.es )
#
#  Based on work by Ryan Dahl in 
#  http://www.math.rochester.edu/people/grads/rld/bayesnets  
#  
#  == Import formats implemented
#  * XML BIF ( XML-based BayesNets Interchange Format , 
#  http://www.cs.cmu.edu/afs/cs/user/fgcozman/www/Research/InterchangeFormat/ )  
#
#
#
##############################################################
require 'rexml/document'
include REXML

#
class BayesNet < DirectedAdjacencyGraph

def create_from_xmlbif(file, bn=self)
    doc = Document.new File.open(file, "r")

    # first go through and add the variables
    doc.elements.each("BIF/NETWORK/VARIABLE") { |variable|

      name = variable.elements["NAME"]

      outcomes = []
      variable.elements.each("OUTCOME") { |outcome|
        outcomes << outcome.text
      }
      # transform from text to boolean
      if outcomes.size == 2 and outcomes.include?("true") and outcomes.include?("false")
        outcomes = outcomes.collect {|o| o == "true"}
      end
      node = BayesNetNode.new( name.text, outcomes )
      bn.add_vertex(node)
    }

    # for each variable we list, we will look up 
    # the conditional probability table for it.

    doc.elements.each("BIF/NETWORK/DEFINITION/") { |definition|
      node = get_variable( definition.elements["FOR"].text )
      givens_array = []
      definition.elements.each("GIVEN") { |given|
        givens_array << get_variable( given.text )
      }

      table = definition.elements["TABLE"].text.split

      givens_array.each { |g| bn.add_edge(g, node) }

      node.set_probability_table(givens_array, table)      
    }
    bn
end

end