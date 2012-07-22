Bayesian Networks for Ruby ( bn4r )
========

bn4r is a bayesian networks library on ruby that provides
the user with classes for create bayesian networks and 
diverse algorithms for solve them.

Its algorithms implementation are based on: S.Russell, P.Norving, "Artificial
Intelligence, A Modern Approach", 2nd Edition.

Website:
http://bn4r.rubyforge.org

Spanish Website:
http://bn4r.rubyforge.org/es


Rubyforge Project:
http://rubyforge.org/projects/bn4r

Dependencies
------

rgl-0.2.3 ( Ruby Graph Library ), http://rgl.rubyforge.org

Design principles
------

The library consists on the object BayesNet thinked to be filled with
BayesNetNode, these objects are defined in bn.rb. BayesNet object is a
especialization of RGL::DirectedAdjacencyGraph ( http://rgl.rubyforge.org ).


The file bn_algorithms.rb has the implementation of the inference algorithms
that can be used to solve BayesNet structures.

Files bn_export.rb and bn_import.rb have methods for import and export bayesian
networked in different formats.

Finally, a set of objects and methods are given to automaticly fill BayesNetNode
probabilities tables.

Usage Examples
------

1. Install the gem ( bn4r-0.9.0.gem )
    
    `gem install bn4r`

2. Include the bn4r

    `require 'bn4r'`

3. Create your first bayes net

		#Create BayesNet
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

		alarm.set_probability_table([burglary,earthquake], [0.95, 0.05, 0.94, 0.06, 0.29, 0.71, 0.001,0.999] )

		john_calls.set_probability_table([alarm], [0.90,0.10,0.05,0.95])
		mary_calls.set_probability_table([alarm], [0.70,0.30,0.01,0.99])

4. Solve it!

		# John and Mary are calling ...
		john_calls.set_value(true)  
		mary_calls.set_value(true)

		# Why?
		is_there_a_burglary = bn_aima.enumeration_ask( burglary, [john_calls, mary_calls] )
		puts "Call the police!" if is_there_a_burglary[0] > is_there_a_burglary[1]

		is_the_alarm_on = bn_aima.enumeration_ask( alarm, [john_calls, mary_calls] )
		puts "Run home, your alarm is distubing the neigborhood!" if is_the_alarm_on[0] > is_the_alarm_on[1]

		is_there_a_earthquake = bn_aima.enumeration_ask( earthquake, [john_calls, mary_calls] )
		puts "Calm yourself, there isn't a earthquake ;)" if is_there_a_earthquake[0] < is_there_a_earthquake[1]	

5. See how your bayes net looks like

		#In .dot format
		bn_aima.to_dot

		# In Microsoft Belief Networks (.xbn) format
		# (download for free in: http://research.microsoft.com/adapt/MSBNx )
		bn_aima.to_xbn


Documentation
------

Documentation can be found at
http://bn4r.rubyforge.org/rdoc
or can be generated using rdoc tool under the source code with:
  rdoc README lib
  
Credits
-----

Thanks to Núria Bel ( http://www.upf.edu/pdi/iula/nuria.bel ) for her work in this project
without her it cannot be done.

Thanks to Ryan Dahl for his work in http://www.math.rochester.edu/people/grads/rld/bayesnets
that was the inspiration of the project.

Also thanks to all the ruby community.

Copying/License
-----

This work is developed by Sergio Espeja ( http://www.upf.edu/pdi/iula/sergio.espeja, sergio.espeja at gmail.com )
mainly in Institut Universitari de Lingüística Aplicada of Universitat Pompeu Fabra ( http://www.iula.upf.es ),
and also in bee.com.es ( http://bee.com.es ).

It is free software, and may be redistributed under GPL license.

Support
-------

Please contact me in http://rubyforge.org/projects/bn4r.