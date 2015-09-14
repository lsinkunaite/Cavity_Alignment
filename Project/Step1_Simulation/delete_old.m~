function delete_old(maxTEM,old_filename)
% Deleting old files
    for ii=0:maxTEM
        for jj=0:ii
            if exist(sprintf(old_filename,num2str(ii-jj),num2str(jj)), 'file')
                delete(sprintf(old_filename,num2str(ii-jj),num2str(jj)));
            end
        end
    end
end