defmodule Actor do
    use GenServer
     #Client
  def start_link(opts) do
    
    [num, max_num , s , w , topology ] = opts
    id= "id#{num}"
    
    rand_line_neighbour =
    if topology=="ImpLine" do
      list1 = Neighbours_for_topologies.get_neighbours(num, max_num , "Full")
      list2 = Neighbours_for_topologies.get_neighbours(num, max_num , "Line")
      list3 = list1 -- list2
      Enum.random(list3)
    else
      0    
    end

    {rand_x , rand_y} =
    if topology=="Rand2D" do
      temp1 = :rand.uniform()
      temp2 = :rand.uniform()
      {temp1,temp2}
    else
      {0,0}    
    end

    

    state = 
    if num==0 do
      count_of_dead_processes = 0      
      neighbour_meta_list = []
      start_time = -1
      finish_time = 0
      [max_num , count_of_dead_processes ,  neighbour_meta_list, start_time , finish_time]
    else
      num_gossip = 0
      pushsum_counter = 0
      [num, max_num , s , w , num_gossip , topology , pushsum_counter , rand_line_neighbour , rand_x ,rand_y  ]
    end
     
    GenServer.start_link(__MODULE__, state,name: :"#{id}")        
  end
  

  
  
  def gossip_receive(pid, rumour) do       
    GenServer.cast(pid, {:gossip_receive, rumour})    
  end

  def gossip_send(pid, rumour) do       
    GenServer.cast(pid, {:gossip_send, rumour})    
  end
  
  def pushsum(pid, s , w) do       
    GenServer.cast(pid, {:pushsum, s , w})    
  end  

  def tracker_gossip(pid ,  time) do       
    GenServer.cast(pid, {:tracker_gossip , time})    
  end

  def tracker_pushsum(pid , ratio , time) do       
    GenServer.cast(pid, {:tracker_pushsum , ratio , time})    
  end

  

  def get_state(pid) do
    GenServer.call(pid, {:get_state})
  end

  def update_state(pid, meta_list) do
    GenServer.call(pid, {:update_state , meta_list})
  end

  def look_up(pid, num) do
    GenServer.call(pid, {:look_up , num})
  end

  # Server (callbacks)

  def init(args) do
    {:ok, args}
  end

  def handle_cast({:gossip_receive, rumour},state) do
    
    [num, max_num , s , w , num_gossip , topology , pushsum_counter ,rand_line_neighbour , rand_x ,rand_y ] = state
    if num_gossip == 0 do
      gossip_send(:"id#{num}",rumour)
    end

    num_gossip = num_gossip + 1    
    if num_gossip == 10 do      
      state = [num, max_num , s , w , num_gossip , topology , pushsum_counter ,rand_line_neighbour , rand_x ,rand_y ] 
      
      tracker_gossip(:id0,System.system_time(:millisecond))     
      {:stop, :normal, state}
    else
      
      state = [num, max_num , s , w , num_gossip , topology , pushsum_counter ,rand_line_neighbour , rand_x ,rand_y ]       
      {:noreply, state}
      
    end
    
    
  end 

  def handle_cast({:gossip_send, rumour},state) do
    try do
      [num, max_num , s , w , num_gossip , topology , pushsum_counter ,rand_line_neighbour , rand_x ,rand_y ] = state      
      neighbour_list = Neighbours_for_topologies.get_neighbours(num , max_num , topology)
      templist1 =
      if topology == "ImpLine" do
        [rand_line_neighbour]
      else
        []
      end
      templist2 =
      if topology == "Rand2D" do
        look_up(:id0,num)  
      else
        []
      end
      neighbour_list = neighbour_list ++  templist1 ++ templist2

      if neighbour_list != [] do
        neighbour = Enum.random(neighbour_list)
        gossip_receive(:"id#{neighbour}",rumour)  
      end
      
      
      
    
    after
      [num, max_num , s , w , num_gossip , topology , pushsum_counter ,rand_line_neighbour , rand_x ,rand_y ] = state      
      :timer.sleep(1)
      gossip_send(:"id#{num}",rumour)
    end

    {:noreply, state}
    
      
  end 
  


  def handle_cast({:pushsum, s,w},state) do
    [num, max_num , s_old , w_old , num_gossip , topology , pushsum_counter ,rand_line_neighbour , rand_x ,rand_y ] = state    
    s_new = s_old + s
    w_new = w_old + w
    temp1 = s_new/w_new
    temp2 = s_old/w_old
    temp3 = temp1 - temp2       
    tracker_pushsum(:id0,temp1,System.system_time(:millisecond)) 
    
      
    pushsum_counter=
    if abs(temp3) <= 0.0000000001 do
      pushsum_counter + 1
    else
      0
    end    
    
    if pushsum_counter == 3 do       
      state =  [num, max_num , s_new , w_new , num_gossip , topology , pushsum_counter ,rand_line_neighbour , rand_x ,rand_y ]
                 
      {:stop, :normal, state} 
    else
      s_keep = s_new/2
      w_keep = w_new/2
      state =  [num, max_num , s_keep , w_keep , num_gossip , topology , pushsum_counter ,rand_line_neighbour , rand_x ,rand_y ]
      neighbour_list = Neighbours_for_topologies.get_neighbours(num , max_num , topology)
      
      templist1 =
      if topology == "ImpLine" do
        [rand_line_neighbour]
      else
        []
      end
      
      templist2 =
      if topology == "Rand2D" do
        look_up(:id0,num)  
      else
        []
      end
      
      neighbour_list = neighbour_list ++ templist1 ++ templist2
      
      if neighbour_list != [] do
        
        neighbour = Enum.random(neighbour_list)                
        pushsum(:"id#{neighbour}", s_keep , w_keep)
        
      end 
            
      {:noreply, state}
      
    end
    
    
  end


  def handle_cast({:tracker_gossip, time},state) do
    [max_num , count_of_dead_processes ,  neighbour_meta_list,start_time , finish_time] = state

    {start_time , finish_time , count_of_dead_processes} = 
    if start_time == -1 do
      {time, finish_time , count_of_dead_processes}  
    else
      {start_time,time , count_of_dead_processes+1}
    end
    time_taken = finish_time - start_time
    
    state = [max_num , count_of_dead_processes ,  neighbour_meta_list, start_time , finish_time]
    

    {:noreply, state}
  end

  def handle_cast({:tracker_pushsum, ratio,time},state) do
    [max_num , count_of_dead_processes ,  neighbour_meta_list, start_time , finish_time] = state 
    {start_time , finish_time} = 
    if start_time == -1 do
      {time, finish_time}  
    else
      {start_time,time}
    end
    time_taken = finish_time - start_time
    
    state = [max_num , count_of_dead_processes ,  neighbour_meta_list, start_time , finish_time]
    
    {:noreply, state}
  end

  

  def handle_call({:get_state}, _from, state) do
      {:reply, state, state}
  end

  def handle_call({:update_state,meta_list}, _from, state) do
    [max_num , count_of_dead_processes , neighbour_meta_list, start_time , finish_time] = state 
    neighbour_meta_list = meta_list
    
    state = [max_num , count_of_dead_processes ,  neighbour_meta_list, start_time , finish_time]
    {:reply, :ok, state}
  end
  
  def handle_call({:look_up,num}, _from, state) do
    [max_num , count_of_dead_processes ,  neighbour_meta_list, start_time , finish_time] = state 
    nlist = Enum.at(neighbour_meta_list,num-1)
        
    {:reply, nlist, state}
  end
    
  
  
end