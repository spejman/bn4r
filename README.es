
= Redes Bayesianas para Ruby ( bn4r )

bn4r es una librería de redes bayesianas en Ruby que proporciona
al usuario clases para crear redes bayesianas y varios algoritmos
para resolverlas.

La implementación de los algoritmos está basada en: S.Russell, P.Norving, "Artificial
Intelligence, A Modern Approach", 2nd Edition.

Página web:
http://bn4r.rubyforge.org/es

Página web (versión inglesa):
http://bn4r.rubyforge.org

Proyecto en Rubyforge:
http://rubyforge.org/projects/bn4r

== Dependencias

* rgl-0.2.3 ( Ruby Graph Library ), http://rgl.rubyforge.org

== Principios de diseño

La librería consiste en el objeto BayesNet pensado para llenarse con
objetos del tipo BayesNetNode, estos objetos están definidos en bn.rb.
El objeto BayesNet es una especialización de RGL::DirectedAdjacencyGraph ( http://rgl.rubyforge.org ).

En el archivo bn_algorithms.rb está la implementación de los algorimos de inferencia
que resuelven las estructuras BayesNet creadas con la librería.

Los archivos bn_export.rb y bn_import.rb contienen métodos para importar y exportar las
redes bayesianas en varios formatos.

Finalmente se distribuyen unos métodos para rellenar automáticamente las tablas
de probabilidades condicionadas de los nodos de la red bayesiana (BayesNetNode)

== Jugando un poco ...

1. Instalar la ruby gem ( bn4r-0.1.2.gem )
	gem install bn4r

2. Incluir bn4r
	require 'bn4r'

3. Crear tu primera red bayesiana

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

6. Resolverla!
	
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

7. Ver que pinta tiene la red bayesiana creada

	# In .dot format
	bn_aima.to_dot
	
	# In Microsoft Belief Networks (.xbn) format
	# (download for free in: http://research.microsoft.com/adapt/MSBNx )
	bn_aima.to_xbn

== Documentación

Se puede encontrar Documentación en ingles en la dirección
http://bn4r.rubyforge.org/rdoc
o se puede generar con rdoc con el comando:
  rdoc README lib
  
== Creditos

Gracias a Núria Bel ( http://www.upf.edu/pdi/iula/nuria.bel ) por su trabajo en este proyecto
sin ella no se podría haber hecho.

Gracias a Ryan Dahl por su trabajo en http://www.math.rochester.edu/people/grads/rld/bayesnets,
fue la idea base del proyecto.

También gracias a toda la comunidad ruby.

== Copyright

Este trabajo esta desarrollado por Sergio Espeja ( http://www.upf.edu/pdi/iula/sergio.espeja, sergio.espeja en gmail.com )
principalmente en el Institut Universitari de Lingüistica Aplicada de la Universitat Pompeu Fabra ( http://www.iula.upf.es ),
y en bee.com.es ( http://bee.com.es ).

Es software libre y debe distribuirse bajo la licencia GPL.
It is free software, and may be redistributed under GPL license.

== Soporte

Contactarme en http://rubyforge.org/projects/bn4r.