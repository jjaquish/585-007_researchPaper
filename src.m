clear
clc

casefile = 'case300.m';

mpc = loadcase(casefile);

G = digraph;
G = addnode(G,size(mpc.bus,1));

BR_STATUS = 11;

for i = 1:size(mpc.branch,1)
    G = addedge(G,mpc.branch(i,1),mpc.branch(i,2));
end

in_deg_cent = centrality(G, 'indegree');
out_deg_cent = centrality(G, 'outdegree');
in_close_cent = centrality(G, 'incloseness');
out_close_cent = centrality(G, 'outcloseness');
pr_cent = centrality(G, 'pagerank');
betw_cent = centrality(G, 'betweenness');
hub_cent = centrality(G, 'hubs');
auth_cent = centrality(G, 'authorities');

ac_successes = zeros(size(mpc.bus,1),8);
dc_successes = zeros(size(mpc.bus,1),2);

for j = 1:size(mpc.bus,1)
    j
    mpc = loadcase(casefile);
    
    G = digraph;
    G = addnode(G,size(mpc.bus,1));
    
    for i = 1:size(mpc.branch,1)
        G = addedge(G,mpc.branch(i,1),mpc.branch(i,2));
    end
    
    G = rmnode(G,j);
    
    for k = 1:size(mpc.branch,1)
        if ((mpc.branch(k, 1) == j) || (mpc.branch(k, 2) == j))
            mpc.branch(k, BR_STATUS) = 0;
        end
    end
    
    opt_1 = mpoption('OUT_ALL', 0);
    [result_ofp, success_opf] = runopf(mpc, opt_1);
    [result_pf, success_pf] = runpf(mpc, opt_1);
    ac_successes(j,1) = success_opf;
    ac_successes(j,2) = success_pf;
    opt_2 = mpoption('PF_ALG',2,'OUT_ALL',0);
    [result_ofp, success_opf] = runopf(mpc,opt_2);
    [result_pf, success_pf] = runpf(mpc,opt_2);
    ac_successes(j,3) = success_opf;
    ac_successes(j,4) = success_pf;
    opt_3 = mpoption('PF_ALG',3,'OUT_ALL',0);
    [result_ofp, success_opf] = runopf(mpc,opt_3);
    [result_pf, success_pf] = runpf(mpc,opt_3);
    ac_successes(j,5) = success_opf;
    ac_successes(j,6) = success_pf;
    opt_4 = mpoption('PF_ALG',4,'OUT_ALL',0);
    [result_ofp, success_opf] = runopf(mpc,opt_4);
    [result_pf, success_pf] = runpf(mpc,opt_4);
    ac_successes(j,7) = success_opf;
    ac_successes(j,8) = success_pf;
    opt_5 = mpoption('PF_DC', 1,'OUT_ALL',0);
    [result_ofp, success_opf] = runopf(mpc,opt_5);
    [result_pf, success_pf] = runpf(mpc,opt_5);
    dc_successes(j,1) = success_opf;
    dc_successes(j,2) = success_pf;
end

for l = 1:size(success(1))
    if(ac_successes(l,:))
        ac_success = [ac_success, l];
    end
    if(dc_successes(1,:))
        dc_success = [dc_success, 1];
    end
end

ac_success;
dc_success;