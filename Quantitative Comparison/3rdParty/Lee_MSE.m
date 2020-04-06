function score = Lee_MSE( GT, I )
    D = GT-I;
    score = mean(mean((D(:,:,1).^2+D(:,:,2).^2+D(:,:,3).^2).^0.5));
end

