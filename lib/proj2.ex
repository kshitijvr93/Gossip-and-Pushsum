defmodule Proj2 do
 
  def main(max_num,algorithm,topology,killed_num_nodes) do

    Controller.start_link(max_num,topology)
    
    
    if topology =="Rand2D" do
        list1 = get_all_states(1,max_num,[])
        
        metalist = create_meta_list( list1 , 1 , max_num , [])  
            
        Actor.update_state(:id0,metalist)
    
    end 

    
    if killed_num_nodes != 0 do      
      gossip_failure(max_num,killed_num_nodes,0)  
    end
    



    random_number = pick_random_actor(max_num)
    cond do

      algorithm == "gossip" ->
        rumour="Hello World!!!!"
        Actor.tracker_gossip(:id0,System.system_time(:millisecond))      
        Actor.gossip_receive(:"id#{random_number}", rumour)
        

      algorithm == "pushsum" ->
        Actor.tracker_pushsum(:id0,0,System.system_time(:millisecond)) 
        Actor.pushsum(:"id#{random_number}",0,0)
      
 
 
 
      true -> IO.puts("Enter appropriate algorithm")
    end
    
  end
  
  def get_all_states(num , max_num , list) when num == max_num do
    state_p = Actor.get_state(:"id#{num}")
    [num_get, max_num , s , w , num_gossip , topology , pushsum_counter , rand_line_neighbour , rand_x ,rand_y  ] = state_p
    list = list ++ [[num,rand_x,rand_y]]
    list  
  end
  def get_all_states(num , max_num , list) do
    state_p = Actor.get_state(:"id#{num}")
    [num_get, max_num , s , w , num_gossip , topology , pushsum_counter , rand_line_neighbour , rand_x ,rand_y  ] = state_p
    list = list ++ [[num,rand_x,rand_y]]
    get_all_states(num+1, max_num , list)
  end

  def create_meta_list( input_list , num , max_num , output_meta_list) when num == max_num do
    x = Enum.at(Enum.at(input_list,num-1) , 1)  
    y = Enum.at(Enum.at(input_list,num-1) , 2)
    list = inner_loop( input_list , 1, max_num , x , y , [])
    list = list --[num]
    output_meta_list = output_meta_list ++ [list]
     
    output_meta_list  
    
  end
  def create_meta_list( input_list , num , max_num ,output_meta_list) do
    x = Enum.at(Enum.at(input_list,num-1) , 1)  
    y = Enum.at(Enum.at(input_list,num-1) , 2)    
    list = inner_loop( input_list , 1, max_num , x , y , [])
    list = list --[num]
    
    output_meta_list = output_meta_list ++ [list]
    
    create_meta_list( input_list , num+1 , max_num ,output_meta_list)
  end

  def inner_loop( input_list , num , max_num ,x,y , output_list) when num == max_num do
    
    x1 = Enum.at(Enum.at(input_list,num-1) , 1)  
    y1 = Enum.at(Enum.at(input_list,num-1) , 2)

    temp1 = x1 - x
    temp2 = y1 - y
    temp3 = (temp1*temp1) + (temp2*temp2)
    distance = :math.pow(temp3,(1/2))

    output_list = 
    if distance<= 0.1 do
      output_list ++ [num]
    else
      output_list ++ []
    end
    
    output_list
  end
  def inner_loop( input_list , num , max_num , x,y, output_list) do
    
    x1 = Enum.at(Enum.at(input_list,num-1) , 1)  
    y1 = Enum.at(Enum.at(input_list,num-1) , 2)
    
    temp1 = x1 - x
    temp2 = y1 - y
    temp3 = (temp1*temp1) + (temp2*temp2)
    distance = :math.pow(temp3,(1/2))

    output_list = 
    if distance<= 0.1 do
      output_list ++ [num]
    else
      output_list ++ []
    end

    inner_loop(input_list , num+1 , max_num , x,y , output_list)

  end

  def gossip_failure(max_num,nodes_to_fail,nodes_failed) when nodes_failed > nodes_to_fail do
    IO.puts("#{nodes_to_fail} number of random nodes have failed")
  
  end

  def gossip_failure(max_num,nodes_to_fail,nodes_failed) do
    fail_node = Enum.random(1..max_num)
    fail_node_id = Process.whereis(:"id#{fail_node}")    
    if fail_node_id != nil do
      Process.exit(fail_node_id,:shutdown)
      IO.inspect(nodes_failed)
      gossip_failure(max_num,nodes_to_fail,nodes_failed+1)
    else
      gossip_failure(max_num,nodes_to_fail,nodes_failed)
    end
  end
        
  def pick_random_actor(max_num) do
    random_node = Enum.random(1..max_num)
    random_node_id = Process.whereis(:"id#{random_node}") 
    if random_node_id == nil do
      pick_random_actor(max_num)
    else
      random_node 
    end 
  end

end
