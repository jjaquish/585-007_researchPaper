clear
clc

casefile = 'case57.m';

mpc = loadcase(casefile);

G = digraph;
G = addnode(G,size(mpc.bus,1));


j = 1;
while j <= size(mpc.branch,1)
    G = addedge(G,mpc.branch(j,1),mpc.branch(j,2));
    j = j + 1;
end


in_deg_cent = centrality(G, 'indegree');
out_deg_cent = centrality(G, 'outdegree');
in_close_cent = centrality(G, 'incloseness');
out_close_cent = centrality(G, 'outcloseness');
pr_cent = centrality(G, 'pagerank');
betw_cent = centrality(G, 'betweenness');
hub_cent = centrality(G, 'hubs');
auth_cent = centrality(G, 'authorities');