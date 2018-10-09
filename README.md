Brief Description:

This problem is aimed at implementing the Gossip and Push-Sum algorithms for information propagation.

These algorithms are in turn implemented on various topologies like full,3D Grid, Random 2D Grid, Sphere, line and imperfect line.

•	The Gossip protocol works by initiating the process from a single actor which forwards the message to the other actors. Once infected with a rumour a node keeps sending gossip messages to one of it’s randomly selected neighbor from the neighbor list. A node dies typically when it has received the copy of gossip enough number of times( for our case its 10).The point of convergence is reached when the number of dead actors gets stabilized.

•	The Push-Sum algorithm works by sending messages in the form of pairs(s,w) where s is the value of the actor number and w = 1 for each actor. The propagation converges when the s/w ratio doesn’t change when compared to a pre-defined value (10^-10 in our case) for three consecutive times.

Network topologies Used:

•	A full network is a topology in which every node is connected to every other node and a message is sent from one actor to any other actor in a random fashion.

•	3D Grid network is a topology in which an actor sends messages to its immediate neighbour be it Up, Down , Left, Right , Front and Back if they exist. The neighbour is selected at random from the neighbour list.

•	Rand2D is decided by first randomly allocating a node on a 2D plane between square given by [0,0],[0,1],[1,0],[1,1]. And the neighbours are decided by the distance between the assigned values in plane.( for our case its <=0.1)

•	Torus/Sphere consists of curved geometry with each node having 4 neighbours, 2 in the plane of cross-section and 2 in the plane of the circle viewed from top.

•	Imperfect 2D behaves like a Line network except that it sends an extra message to a random neighbour in the network.

•	Line topology involves sending messages back and forth to an actor’s front and back neighbours.


