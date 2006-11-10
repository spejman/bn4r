require File.dirname(__FILE__) + '/../lib/bn4r'
require 'bn_test_models'

def main
#  bn = BayesNet.new.create_from_xmlbif("dog-problem.bif")
  bn = bayes_net_aima
#  print "Created bn"
  print bn.to_xbn
end

main