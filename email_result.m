function email_result(fitting_path,L_from,L_to,maxTEM,code_path,email_address,subject_message,message,files_to_send)
    % Sends email with result files
    listDir=dir(sprintf(files_to_send));
    list={listDir.name};
    cd(fitting_path);
    %setpref('Internet','E_mail', 'laura.sinkunaite@ligo.org');
    %setpref('Internet','SMTP_Server','bepex.ligo-wa.caltech.edu');
    sendmail(email_address,subject_message,message,list);
    cd(code_path);
end