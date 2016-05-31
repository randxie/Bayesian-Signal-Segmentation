% generate simulation data
function y = simulation(para)
    y = zeros(para.sim_len,1);
    idx_change_pt = 1;
    ARcoeff = para.ARcoeff(idx_change_pt,:);
    ARorder = length(ARcoeff);
    noise = para.noise_level*randn(para.sim_len);
    y(1:ARorder) = para.y0;
    for i = (ARorder+1):para.sim_len
        y(i) = sim_ar(y((i-ARorder):(i-1)),ARcoeff) + noise(i);
        if (idx_change_pt <= length(para.change_point))
            if (i==para.change_point(idx_change_pt))
                idx_change_pt = idx_change_pt + 1;
                ARcoeff = para.ARcoeff(idx_change_pt,:); 
            end
        end
    end
end


function [y_new] = sim_ar(y_old, ARcoeff)
    y_new = ARcoeff*flipud(y_old);
end
