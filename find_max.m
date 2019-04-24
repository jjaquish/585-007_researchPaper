function loc = find_max(vector)
    i = 1;
    max_loc = 0;
    temp = 0.0;
    while i <= size(vector,1)
        if (vector(i) > temp)
            temp = vector(i);
            max_loc = i;
        end
        i = i + 1;
    end
    loc = max_loc;
end