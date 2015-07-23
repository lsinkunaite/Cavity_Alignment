function email_result(fitting_path,L_from,L_to,maxTEM,code_path)
    % Sends email with result files
    listDir=dir(sprintf('%sfitting_HG*.txt',fitting_path));
    list={listDir.name};
    email_address='laura.sinkunaite@ligo-wa.caltech.edu';
    subject_message='Run complete!';
    message=sprintf('L_from=%f, L_to=%f, maxTEM=%d',L_from,L_to,maxTEM);
    cd(fitting_path);
    %setpref('Internet','E_mail', 'laura.sinkunaite@ligo.org');
    %setpref('Internet','SMTP_Server','bepex.ligo-wa.caltech.edu');
    sendmail(email_address,subject_message,message,list);
    cd(code_path);
end