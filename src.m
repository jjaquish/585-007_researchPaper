clear
clc

%initial parameter setup
casefile = 'case14.m';

mpc = loadcase(casefile);

G = digraph;
G = addnode(G,size(mpc.bus,1));

BR_STATUS = 11;
i = 1;
while i <= size(mpc.branch,1)
    G = addedge(G,mpc.branch(i,1),mpc.branch(i,2));
    i = i+1;
end

in_deg_cent = centrality(G, 'indegree');
out_deg_cent = centrality(G, 'outdegree');
in_close_cent = centrality(G, 'incloseness');
out_close_cent = centrality(G, 'outcloseness');
pr_cent = centrality(G, 'pagerank');
betw_cent = centrality(G, 'betweenness');
hub_cent = centrality(G, 'hubs');
auth_cent = centrality(G, 'authorities');
%A matrix to store all desired values
success = zeros(size(mpc.bus,1), 2);

%Network results and data without interferance
original_P = zeros(size(mpc.bus,1),1);
original_Q = zeros(size(mpc.bus,1),1);

prim_result = runopf(mpc);

prim_load_P = sum(prim_result.bus(:,3));
prim_load_Q = sum(prim_result.bus(:,4));
prim_gen_P = sum(prim_result.gen(:,2));
prim_gen_Q = sum(prim_result.gen(:,3));
%A matrix to export the 'useful' data
results = zeros(size(mpc.bus,1), 18);

for p = 1:size(mpc.bus,1)
    original_P(p) = mpc.bus(p,3);
    original_Q(p) = mpc.bus(p,4);
end
for j = 1:size(mpc.bus,1)
    if(mpc.bus(j,2)~=3 && mpc.bus(j,2)~=2)
        %Regenerates initial case and graph parameters.
        mpc = loadcase(casefile);
        G = digraph;
        G = addnode(G,size(mpc.bus,1));
    
        for i = 1:size(mpc.branch,1)
            G = addedge(G,mpc.branch(i,1),mpc.branch(i,2));
        end
        G = rmnode(G,j);
        results(j,2) = mpc.bus(j,2);
        %changes the type of bus and turns of load and generation capacity
        %for the bus being removed
        mpc.bus(j,2) = 4;
        mpc.bus(j,3) = 0;
        mpc.bus(j,4) = 0;
        mpc.bus(j,5) = 0;
        mpc.bus(j,6) = 0;
        %set the branches to the removed node to zero
        for k = 1:size(mpc.branch,1)
            if ((mpc.branch(k, 1) == j) || (mpc.branch(k, 2) == j))
                mpc.branch(k, BR_STATUS) = 0;
            end
        end
               
        opt = mpoption('VERBOSE', 0, 'OUT_ALL', 0);
        [result_opf, success_opf] = runopf(mpc,opt);
        success(j,1) = success_opf;    
        [result_pf, success_pf] = runpf(mpc, opt);
        success(j,2) = success_pf;
        if(success_opf) %If the run is successful
            total_load_P = sum(result_opf.bus(:,3));
            total_load_Q = sum(result_opf.bus(:,4));
            total_gen_P = sum(result_opf.gen(:,2));
            total_gen_Q = sum(result_opf.gen(:,3));
            %Store all the important variable outputs in a matrix. Prim
            %means primary and those values come from the initial
            %calculations
            results(j,1) = success(j,1);                
            results(j,3) = total_load_P;
            results(j,4) = total_load_Q;
            results(j,5) = total_gen_P;
            results(j,6) = total_gen_Q;
            results(j,7) = total_load_P/prim_load_P;
            results(j,8) = total_load_Q/prim_load_Q;
            results(j,9) = total_gen_P/prim_gen_P;
            results(j,10) = total_gen_Q/prim_gen_Q;
            results(:,11) = in_deg_cent;
            results(:,12) = out_deg_cent;
            results(:,13) = in_close_cent;
            results(:,14) = out_close_cent;
            results(:,15) = pr_cent;
            results(:,16) = betw_cent;
            results(:,17) = hub_cent;
            results(:,18) = auth_cent;
            
        else
            total_load_P = 0;
            total_load_Q = 0;
            total_gen_P = 0;
            total_gen_Q = 0;
        end
        
        

        
        %{
        After testing, none of the AC_PF and AC_OPF methods were more effective
        than the others. Newton's method will be chosen as the default and is
        left uncommented above. AC_PF and AC_OPF were indistinguishable in
        terms of convergences. Therefore AC_OPF will be used as the default.
        AC_PF has been commented out above. 
        
        opt_2 = mpoption('PF_ALG', 2,'VERBOSE', 0, 'OUT_ALL', 0);
        [result_ofp, success_opf] = runopf(mpc, opt_2);
        [result_pf, success_pf] = runpf(mpc, opt_2);
        success(j,3) = success_opf;
        success(j,4) = success_pf;
        opt_3 = mpoption('PF_ALG',3,'VERBOSE', 0, 'OUT_ALL', 0);
        [result_ofp, success_opf] = runopf(mpc, opt_3);
        [result_pf, success_pf] = runpf(mpc, opt_3);
        success(j,5) = success_opf;
        success(j,6) = success_pf;
        opt_4 = mpoption('PF_ALG',4,'VERBOSE', 0, 'OUT_ALL', 0);
        [result_ofp, success_opf] = runopf(mpc, opt_4);
        [result_pf, success_pf] = runpf(mpc, opt_4);
        success(j,7) = success_opf;
        success(j,8) = success_pf;
        %}
           
        %After testing, DC_PF always converged when AC_PF converged, but the opposite wasn't true.
        %However the lines below are kept to serve as a reference for the
        %proof that DC does not measure failure as well as AC
        opt_5 = mpoption('PF_DC', 1,'VERBOSE', 0, 'OUT_ALL', 0);
        [result_opf, success_opf] = runopf(mpc, opt_5);    
        [result_pf, success_pf] = runpf(mpc, opt_5);
        dc_success(j,1) = success_opf;    
        dc_success(j,2) = success_pf;
        
        %{
        while(~success(j,1) & success(j,1)~=2)
            success(j,1) = 2;
        
            for m = 1:size(mpc.bus,1)
                mpc.bus(m,3) = 0.95*mpc.bus(m,3);
                mpc.bus(m,4) = 0.95*mpc.bus(m,4);
                if mpc.bus(m,3) <= 0.2*original_P(m)
                    for n = 1:size(mpc.branch,1)
                        if ((mpc.branch(n, 1) == j) || (mpc.branch(n, 2) == j))
                            success(j,1) = 2;
                            mpc.branch(n, BR_STATUS) = 0;
                            mpc.bus(n,2) = 4;
                        end
                    end
                elseif mpc.bus(m,4) <= 0.2*original_Q(m)
                    for o = 1:size(mpc.branch,1)
                        if ((mpc.branch(o, 1) == j) || (mpc.branch(o, 2) == j))
                            success(j,1) = 2;
                            mpc.branch(o, BR_STATUS) = 0;
                            mpc.bus(n,2) = 4;
                        end
                    end
                end
            end
            [result_ofp, success_opf] = runopf(mpc);
            success(j,1) = success_opf;
        
        end 
        %}
        
        %{
        success_1 = success;
        if(~success(j,1))
            for t = 1:10
                mpc.bus = scale_load(t/10,mpc.bus);            
            endr
        end
        %}
    end
        
end

output = zeros(size(mpc.bus, 1), 10);
output(:,1) = results(:,1);
output(:,2) = results(:,9);

for r = 3:10
    output(:,r) = results(:,r+8);
end

T = array2table(output, 'VariableNames', {'Success', 'PowerGenerationPercent', 'InDegreeCentrality', 'OutDegreeCentrality', 'InCloseCentrality', 'OutCloseCentrality', 'PageRankCentrality', 'BetweennessCentrality', 'HubCentrality', 'Authorities'});
if(strcmp(casefile,'case118.m'))
    filename = '118_Results.xlsx';
elseif(strcmp(casefile,'case14.m'))
    filename = '14_Results.xlsx';
elseif(strcmp(casefile,'case30.m'))
    filename = '30_Results.xlsx';
elseif(strcmp(casefile,'case57.m'))
    filename = '57_Results.xlsx';
else
    fprintf('Unknown File. Saving to File: Results.xlsx');
    fliename = 'Results.xlsx';
end

writetable(T,filename,'Sheet',1);
