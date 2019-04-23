casefile = 'case300.m'

mpc = loadcase(casefile);

G = digraph;
G = addnode(G,size(mpc.bus,1));


j = 1;
while j <= size(mpc.branch,1)
    G = addedge(G,mpc.branch(j,1),mpc.branch(j,2));
    j = j + 1;
end

plot(G);
runpf(casefile);

