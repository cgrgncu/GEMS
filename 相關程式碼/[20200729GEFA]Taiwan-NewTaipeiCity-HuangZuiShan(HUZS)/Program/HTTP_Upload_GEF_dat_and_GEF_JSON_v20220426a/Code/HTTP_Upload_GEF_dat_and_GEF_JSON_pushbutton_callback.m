%**************************************************************************
%   Name: HTTP_Upload_GEF_dat_and_GEF_JSON_pushbutton_callback.m v20201019a
%   Copyright:  
%   Author: HsiupoYeh 
%   Version: v20201019a
%   Description: HTTP_Upload_GEF_dat_and_GEF_JSON�{�����^�s���
%   �B��ݨD�~���ɮ�:
%                  GEF_dat_to_GEF_JSON.m
%                  read_GEF_dat_to_GEF_mat.m
%                  curl.exe
%                  libcurl.dll
%**************************************************************************    
    %--
    % ��s���s���e
    set(ui_pushbutton01_handle,'String','�B�椤')
    set(ui_pushbutton01_handle,'Enable','off')    
	%--
    % ���w�O����x��    
    diary(['log/HTTP_Upload_GEF_dat_and_GEF_JSON_',datestr(now,'yyyymmdd'),'.log']) % �o�̫��w�s���ɦW
	% �}�l�����R�O�C����r
    diary on;
    %--
% �L�a�j��
%--
while (1)
    %--
    disp(['�{�b�ɶ�: ',datestr(now,'yyyy-mm-dd HH:MM:SS')])
    for i_day=1:str2num(main_program_parameter.Target_HTTP.Target_HTTP_check_day_count_from_today_UTCp8)
        temp_time=now-i_day;
        disp(['�ˬd�ɶ�: ',datestr(temp_time,'yyyy-mm-dd HH:MM:SS')])
        input_file_folder=[main_program_parameter.Local.Local_storage_path,'\','Y',datestr(temp_time,'yyyy'),'\M',datestr(temp_time,'mm'),'\D',datestr(temp_time,'dd'),'\'];
        temp_dir_result=dir([input_file_folder,'\*.dat'])';
        input_file_name_cell={temp_dir_result.name}';
        if (length(input_file_name_cell)==144)
            disp('���adat�ɮצs�b!�ˬd�����ɮ׬O�_�s�b...')
            %disp((['curl.exe -s -d "{\"Version\":\"20200824a\",\"SiteName\":\"',main_program_parameter.GEF_INFO.GEF_INFO_station_full_name,'\",\"GEF_JSON_FileName\":\"',datestr(temp_time,'yyyy_mm_dd'),'.json','\",\"CMD\":\"Exist?\"}" -k -H "Content-Type: application/json" -X POST https://cgrg.synology.me/TWGEFN/api/GEF_tool.php']));
            [temp_result, temp_check_result]=system(['curl.exe -s -d "{\"Version\":\"20200824a\",\"SiteName\":\"',main_program_parameter.GEF_INFO.GEF_INFO_station_full_name,'\",\"GEF_JSON_FileName\":\"',datestr(temp_time,'yyyy_mm_dd'),'.json','\",\"CMD\":\"Exist?\"}" -k -H "Content-Type: application/json" -X POST https://cgrg.synology.me/TWGEFN/api/GEF_tool.php']);
            %temp_check_result='{"Return":"0","CMD":"Exist?","Result":"No"}';
            if strcmp(temp_check_result,'{"Return":"0","CMD":"Exist?","Result":"No"}')
                disp('����GEF_JSON���s�b!�ݭn���ɨäW��!')
                disp(['���ɥؼ�:',main_program_parameter.Local.Local_storage_path,'\',input_file_folder,'*.dat']);
                Result=GEF_dat_to_GEF_JSON_1Day_0p1Hz(main_program_parameter.GEF_INFO.GEF_INFO_station_full_name,input_file_folder,input_file_name_cell,'',['temp/',input_file_name_cell{1}(1:10),'.json']);
                if Result.Return_code==0
                    disp('���ɦ��\!�W���ɮ�!')
                    [temp_result, temp_upload_result]=system(['curl -k -s -F "GEF_JSON_File=@temp\',input_file_name_cell{1}(1:10),'.json" -F "Version=20200824a" -F "SiteName=',main_program_parameter.GEF_INFO.GEF_INFO_station_full_name,'" -F "CMD=UploadGEFJSON?" https://cgrg.synology.me/TWGEFN/api/GEF_tool.php']);
                     if strcmp(temp_upload_result,'{"Return":"0","CMD":"UploadGEFJSON?","Result":"Success"}')
                         disp('�W���ɮצ��\!�R�����a�ɮ�!')
                         delete(['temp/',input_file_name_cell{1}(1:10),'.json'])
                     elseif strcmp(temp_upload_result,'{"Return":"0","CMD":"UploadGEFJSON?","Result":"Fail"}')
                         disp('�W���ɮץ���!���L!')
                     else
                         disp('�W���ɮײ��`!���L!')
                     end
                else
                    disp('���ɥ���!���L!')
                end                    
            elseif strcmp(temp_check_result,'{"Return":"0","CMD":"Exist?","Result":"Yes"}')
                disp('����GEF_JSON�s�b!���L!')
            else
                disp('�d�ߩR�O���~!���L!')
            end     
        else
            disp(['���adat�ɮפ�����A�Ф�ʳB�z...�����㪺��Ƨ�:',main_program_parameter.Local.Local_storage_path,'\',input_file_folder])
        end    
    end
    %----------------------------------------------------------------------
    % �Ʊ�W�Ǩ�ؼ�FTP����Ƨ�����M��
    %--
    % �eN�p�ɨ�ثe���ɮײM��A����ϥΥx�_�ɶ�(UTC+8)�C
    % check_hour_count_from_today_UTCp8�N�O�p�ɼơA��ĳ��2�C
    check_hour_count_from_today_UTCp8=str2num(main_program_parameter.Target_HTTP.Target_HTTP_check_hour_count_from_today_UTCp8); 
    %--
    % �إ߲M��
    check_file_list={};
    check_GEF_JSON_file_list={};
    for i=1:check_hour_count_from_today_UTCp8
        % ²�u����榡(�x�_�ɶ�)
        temp_time=now-((i-1)/24);
        check_dat_file_list{i,1}=['Y',datestr(temp_time,'yyyy'),'\M',datestr(temp_time,'mm'),'\D',datestr(temp_time,'dd'),'\'];
        check_dat_file_list{i,2}=[datestr(temp_time,'yyyy_mm_dd_HH_')];
        % �������榡(�x�_�ɶ�)
        check_GEF_JSON_file_list{i,1}=datestr(now-i+1,'yyyymmdd');
    end
    % �վ�M�涶��
    check_dat_file_list=flipud(check_dat_file_list);    
    disp('--')
    disp('�ݭn�ˬd�����')
    for i=1:check_hour_count_from_today_UTCp8
        %exist([main_program_parameter.Local.Local_storage_path,'\',check_dat_file_list{i,1},check_dat_file_list{i,2}])
        for hour_str={'00','10','20','30','40','50'}            
            disp(['#',num2str(i),' ���adat�ɮצW��: ',main_program_parameter.Local.Local_storage_path,'\',check_dat_file_list{i,1},check_dat_file_list{i,2},hour_str{1},'_00.dat'])
            if (exist([main_program_parameter.Local.Local_storage_path,'\',check_dat_file_list{i,1},check_dat_file_list{i,2},hour_str{1},'_00.dat'],'file')==2)
                disp('���adat�ɮצs�b!�ˬd�����ɮ׬O�_�s�b...')
                %   curl -d "{\"Version\":\"20200819a\",\"SiteName\":\"[20200718GEFA]Taiwan-NewTaipeiCity-HuangZuiShan(HUZS)\",\"GEF_JSON_FileName\":\"2020_08_30_23_50_00.json\",\"CMD\":\"Exist?\"}" -k -H "Content-Type: application/json" -X POST https://cgrg.synology.me/TWGEFN/api/GEF_tool.php
                disp((['curl.exe -s -d "{\"Version\":\"20200824a\",\"SiteName\":\"',main_program_parameter.GEF_INFO.GEF_INFO_station_full_name,'\",\"GEF_JSON_FileName\":\"',check_dat_file_list{i,2},hour_str{1},'_00.json','\",\"CMD\":\"Exist?\"}" -k -H "Content-Type: application/json" -X POST https://cgrg.synology.me/TWGEFN/api/GEF_tool.php']));
                [temp_result, temp_check_result]=system(['curl.exe -s -d "{\"Version\":\"20200824a\",\"SiteName\":\"',main_program_parameter.GEF_INFO.GEF_INFO_station_full_name,'\",\"GEF_JSON_FileName\":\"',check_dat_file_list{i,2},hour_str{1},'_00.json','\",\"CMD\":\"Exist?\"}" -k -H "Content-Type: application/json" -X POST https://cgrg.synology.me/TWGEFN/api/GEF_tool.php']);
                %temp_check_result
                if strcmp(temp_check_result,'{"Return":"0","CMD":"Exist?","Result":"No"}')
                    disp('����GEF_JSON���s�b!�ݭn���ɨäW��!')
                    disp(['���ɥؼ�:',main_program_parameter.Local.Local_storage_path,'\',check_dat_file_list{i,1},check_dat_file_list{i,2},hour_str{1},'_00.dat']);
                    Result=GEF_dat_to_GEF_JSON(main_program_parameter.GEF_INFO.GEF_INFO_station_full_name,[main_program_parameter.Local.Local_storage_path,'\',check_dat_file_list{i,1},check_dat_file_list{i,2},hour_str{1},'_00.dat'],'',['temp/',check_dat_file_list{i,2},hour_str{1},'_00.json']);
                    if Result.Return_code==0
                        disp('���ɦ��\!�W���ɮ�!')
                        [temp_result, temp_upload_result]=system(['curl -k -s -F "GEF_JSON_File=@temp\',check_dat_file_list{i,2},hour_str{1},'_00.json" -F "Version=20200819a" -F "SiteName=',main_program_parameter.GEF_INFO.GEF_INFO_station_full_name,'" -F "CMD=UploadGEFJSON?" https://cgrg.synology.me/TWGEFN/api/GEF_tool.php']);
                         if strcmp(temp_upload_result,'{"Return":"0","CMD":"UploadGEFJSON?","Result":"Success"}')
                             disp('�W���ɮצ��\!�R�����a�ɮ�!')
                             delete(['temp/',check_dat_file_list{i,2},hour_str{1},'_00.json'])
                         elseif strcmp(temp_upload_result,'{"Return":"0","CMD":"UploadGEFJSON?","Result":"Fail"}')
                             disp('�W���ɮץ���!���L!')
                         else
                             disp('�W���ɮײ��`!���L!')
                         end
                    else
                        disp('���ɥ���!���L!')
                    end                    
                elseif strcmp(temp_check_result,'{"Return":"0","CMD":"Exist?","Result":"Yes"}')
                    disp('����GEF_JSON�s�b!���L!')
                else
                    disp('�d�ߩR�O���~!���L!')
                end                
            else
                disp('���adat�ɮפ��s�b!���L!')
            end
            disp('--')
        end
    end
    disp('--')
    %----------------------------------------------------------------------    
    %----------------------------------------------------------------------
    % ��������R�O�C����r�A�ñN���e���������e�g���ɮפ��C
    diary off    
    %----------------------------------------------------------------------
    % �˼ƭp�ɬ�ơA�ж�5������
    countdown_in_second=300;%Target_HTTP_loop_sleep_in_second;
    for k=countdown_in_second:-5:1
        %----------------------------------------------------------
        % ��sGUI��r
        program_info_str_cell{22}=['    �˼�',num2str(k),'���A������...'];
        try 
            % ���է�s
            set(ui_listbox01_handle,'String', program_info_str_cell)
        catch ME
            % �L�X�n�J���`�T��
            disp(['���ӬOGUI�Q�����a!return! ���~�T��:',ME.message])
            return
        end        
        %--
        drawnow;
        %----------------------------------------------------------
        disp('�Ȱ�5��...')
        pause(5)% �Ȱ�N��
    end
    %----------------------------------------------------------------------

end   
    