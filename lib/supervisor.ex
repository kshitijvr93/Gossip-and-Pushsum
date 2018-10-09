defmodule Controller do
    use Supervisor
    def start_link(max_num , topology) do       
        children = child_features_arr(max_num,[],max_num,topology)

        children0 = [%{
            id: 0,
            start: {Actor, :start_link, [[0,max_num,0,1,topology]]},
            restart: :permanent,
            shutdown: :brutal_kill
          }]

        children = children ++ children0
        
        IO.puts ".......................................Starting the Supervisor"
        IO.puts ".............................................Starting all the nodes/Actors"
        Supervisor.start_link(children, strategy: :one_for_one)
        
    end

    def child_features_arr(num,children,max_num,topology) when num==1 do
        children = children++[%{ id: num,start: {Actor, :start_link, [[num,max_num,num,1,topology]]} ,  restart: :transient ,shutdown: :brutal_kill }]
        children
    end

    def child_features_arr(num,children,max_num,topology) do
        children = children++[%{ id: num,start: {Actor, :start_link, [[num,max_num,num,1,topology]]} ,  restart: :transient ,shutdown: :brutal_kill }]
        child_features_arr(num-1,children,max_num,topology)
    end  

    
end