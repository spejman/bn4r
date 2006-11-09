require File.dirname(__FILE__) + '/../lib/bn4r'
require 'bn_test_models'

def main
  print bayes_net_aima2.to_dot
end

main