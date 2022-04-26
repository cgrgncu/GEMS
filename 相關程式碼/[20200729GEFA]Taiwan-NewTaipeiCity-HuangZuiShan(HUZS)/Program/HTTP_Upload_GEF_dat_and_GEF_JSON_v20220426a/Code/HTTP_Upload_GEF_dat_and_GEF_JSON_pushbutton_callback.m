%**************************************************************************
%   Name: HTTP_Upload_GEF_dat_and_GEF_JSON_pushbutton_callback.m v20201019a
%   Copyright:  
%   Author: HsiupoYeh 
%   Version: v20201019a
%   Description: HTTP_Upload_GEF_dat_and_GEF_JSON程式的回叫函數
%   運行需求外部檔案:
%                  GEF_dat_to_GEF_JSON.m
%                  read_GEF_dat_to_GEF_mat.m
%                  curl.exe
%                  libcurl.dll
%**************************************************************************    
    %--
    % 更新按鈕內容
    set(ui_pushbutton01_handle,'String','運行中')
    set(ui_pushbutton01_handle,'Enable','off')    
	%--
    % 指定記錄日誌檔    
    diary(['log/HTTP_Upload_GEF_dat_and_GEF_JSON_',datestr(now,'yyyymmdd'),'.log']) % 這裡指定存檔檔名
	% 開始紀錄命令列的文字
    diary on;
    %--
% 無窮迴圈
%--
while (1)
    %--
    disp(['現在時間: ',datestr(now,'yyyy-mm-dd HH:MM:SS')])
    for i_day=1:str2num(main_program_parameter.Target_HTTP.Target_HTTP_check_day_count_from_today_UTCp8)
        temp_time=now-i_day;
        disp(['檢查時間: ',datestr(temp_time,'yyyy-mm-dd HH:MM:SS')])
        input_file_folder=[main_program_parameter.Local.Local_storage_path,'\','Y',datestr(temp_time,'yyyy'),'\M',datestr(temp_time,'mm'),'\D',datestr(temp_time,'dd'),'\'];
        temp_dir_result=dir([input_file_folder,'\*.dat'])';
        input_file_name_cell={temp_dir_result.name}';
        if (length(input_file_name_cell)==144)
            disp('本地dat檔案存在!檢查遠端檔案是否存在...')
            %disp((['curl.exe -s -d "{\"Version\":\"20200824a\",\"SiteName\":\"',main_program_parameter.GEF_INFO.GEF_INFO_station_full_name,'\",\"GEF_JSON_FileName\":\"',datestr(temp_time,'yyyy_mm_dd'),'.json','\",\"CMD\":\"Exist?\"}" -k -H "Content-Type: application/json" -X POST https://cgrg.synology.me/TWGEFN/api/GEF_tool.php']));
            [temp_result, temp_check_result]=system(['curl.exe -s -d "{\"Version\":\"20200824a\",\"SiteName\":\"',main_program_parameter.GEF_INFO.GEF_INFO_station_full_name,'\",\"GEF_JSON_FileName\":\"',datestr(temp_time,'yyyy_mm_dd'),'.json','\",\"CMD\":\"Exist?\"}" -k -H "Content-Type: application/json" -X POST https://cgrg.synology.me/TWGEFN/api/GEF_tool.php']);
            %temp_check_result='{"Return":"0","CMD":"Exist?","Result":"No"}';
            if strcmp(temp_check_result,'{"Return":"0","CMD":"Exist?","Result":"No"}')
                disp('遠端GEF_JSON不存在!需要轉檔並上傳!')
                disp(['轉檔目標:',main_program_parameter.Local.Local_storage_path,'\',input_file_folder,'*.dat']);
                Result=GEF_dat_to_GEF_JSON_1Day_0p1Hz(main_program_parameter.GEF_INFO.GEF_INFO_station_full_name,input_file_folder,input_file_name_cell,'',['temp/',input_file_name_cell{1}(1:10),'.json']);
                if Result.Return_code==0
                    disp('轉檔成功!上傳檔案!')
                    [temp_result, temp_upload_result]=system(['curl -k -s -F "GEF_JSON_File=@temp\',input_file_name_cell{1}(1:10),'.json" -F "Version=20200824a" -F "SiteName=',main_program_parameter.GEF_INFO.GEF_INFO_station_full_name,'" -F "CMD=UploadGEFJSON?" https://cgrg.synology.me/TWGEFN/api/GEF_tool.php']);
                     if strcmp(temp_upload_result,'{"Return":"0","CMD":"UploadGEFJSON?","Result":"Success"}')
                         disp('上傳檔案成功!刪除本地檔案!')
                         delete(['temp/',input_file_name_cell{1}(1:10),'.json'])
                     elseif strcmp(temp_upload_result,'{"Return":"0","CMD":"UploadGEFJSON?","Result":"Fail"}')
                         disp('上傳檔案失敗!略過!')
                     else
                         disp('上傳檔案異常!略過!')
                     end
                else
                    disp('轉檔失敗!略過!')
                end                    
            elseif strcmp(temp_check_result,'{"Return":"0","CMD":"Exist?","Result":"Yes"}')
                disp('遠端GEF_JSON存在!略過!')
            else
                disp('查詢命令錯誤!略過!')
            end     
        else
            disp(['本地dat檔案不完整，請手動處理...不完整的資料夾:',main_program_parameter.Local.Local_storage_path,'\',input_file_folder])
        end    
    end
    %----------------------------------------------------------------------
    % 希望上傳到目標FTP的資料夾日期清單
    %--
    % 前N小時到目前的檔案清單，日期使用台北時間(UTC+8)。
    % check_hour_count_from_today_UTCp8就是小時數，建議填2。
    check_hour_count_from_today_UTCp8=str2num(main_program_parameter.Target_HTTP.Target_HTTP_check_hour_count_from_today_UTCp8); 
    %--
    % 建立清單
    check_file_list={};
    check_GEF_JSON_file_list={};
    for i=1:check_hour_count_from_today_UTCp8
        % 簡短日期格式(台北時間)
        temp_time=now-((i-1)/24);
        check_dat_file_list{i,1}=['Y',datestr(temp_time,'yyyy'),'\M',datestr(temp_time,'mm'),'\D',datestr(temp_time,'dd'),'\'];
        check_dat_file_list{i,2}=[datestr(temp_time,'yyyy_mm_dd_HH_')];
        % 完整日期格式(台北時間)
        check_GEF_JSON_file_list{i,1}=datestr(now-i+1,'yyyymmdd');
    end
    % 調整清單順序
    check_dat_file_list=flipud(check_dat_file_list);    
    disp('--')
    disp('需要檢查的日期')
    for i=1:check_hour_count_from_today_UTCp8
        %exist([main_program_parameter.Local.Local_storage_path,'\',check_dat_file_list{i,1},check_dat_file_list{i,2}])
        for hour_str={'00','10','20','30','40','50'}            
            disp(['#',num2str(i),' 本地dat檔案名稱: ',main_program_parameter.Local.Local_storage_path,'\',check_dat_file_list{i,1},check_dat_file_list{i,2},hour_str{1},'_00.dat'])
            if (exist([main_program_parameter.Local.Local_storage_path,'\',check_dat_file_list{i,1},check_dat_file_list{i,2},hour_str{1},'_00.dat'],'file')==2)
                disp('本地dat檔案存在!檢查遠端檔案是否存在...')
                %   curl -d "{\"Version\":\"20200819a\",\"SiteName\":\"[20200718GEFA]Taiwan-NewTaipeiCity-HuangZuiShan(HUZS)\",\"GEF_JSON_FileName\":\"2020_08_30_23_50_00.json\",\"CMD\":\"Exist?\"}" -k -H "Content-Type: application/json" -X POST https://cgrg.synology.me/TWGEFN/api/GEF_tool.php
                disp((['curl.exe -s -d "{\"Version\":\"20200824a\",\"SiteName\":\"',main_program_parameter.GEF_INFO.GEF_INFO_station_full_name,'\",\"GEF_JSON_FileName\":\"',check_dat_file_list{i,2},hour_str{1},'_00.json','\",\"CMD\":\"Exist?\"}" -k -H "Content-Type: application/json" -X POST https://cgrg.synology.me/TWGEFN/api/GEF_tool.php']));
                [temp_result, temp_check_result]=system(['curl.exe -s -d "{\"Version\":\"20200824a\",\"SiteName\":\"',main_program_parameter.GEF_INFO.GEF_INFO_station_full_name,'\",\"GEF_JSON_FileName\":\"',check_dat_file_list{i,2},hour_str{1},'_00.json','\",\"CMD\":\"Exist?\"}" -k -H "Content-Type: application/json" -X POST https://cgrg.synology.me/TWGEFN/api/GEF_tool.php']);
                %temp_check_result
                if strcmp(temp_check_result,'{"Return":"0","CMD":"Exist?","Result":"No"}')
                    disp('遠端GEF_JSON不存在!需要轉檔並上傳!')
                    disp(['轉檔目標:',main_program_parameter.Local.Local_storage_path,'\',check_dat_file_list{i,1},check_dat_file_list{i,2},hour_str{1},'_00.dat']);
                    Result=GEF_dat_to_GEF_JSON(main_program_parameter.GEF_INFO.GEF_INFO_station_full_name,[main_program_parameter.Local.Local_storage_path,'\',check_dat_file_list{i,1},check_dat_file_list{i,2},hour_str{1},'_00.dat'],'',['temp/',check_dat_file_list{i,2},hour_str{1},'_00.json']);
                    if Result.Return_code==0
                        disp('轉檔成功!上傳檔案!')
                        [temp_result, temp_upload_result]=system(['curl -k -s -F "GEF_JSON_File=@temp\',check_dat_file_list{i,2},hour_str{1},'_00.json" -F "Version=20200819a" -F "SiteName=',main_program_parameter.GEF_INFO.GEF_INFO_station_full_name,'" -F "CMD=UploadGEFJSON?" https://cgrg.synology.me/TWGEFN/api/GEF_tool.php']);
                         if strcmp(temp_upload_result,'{"Return":"0","CMD":"UploadGEFJSON?","Result":"Success"}')
                             disp('上傳檔案成功!刪除本地檔案!')
                             delete(['temp/',check_dat_file_list{i,2},hour_str{1},'_00.json'])
                         elseif strcmp(temp_upload_result,'{"Return":"0","CMD":"UploadGEFJSON?","Result":"Fail"}')
                             disp('上傳檔案失敗!略過!')
                         else
                             disp('上傳檔案異常!略過!')
                         end
                    else
                        disp('轉檔失敗!略過!')
                    end                    
                elseif strcmp(temp_check_result,'{"Return":"0","CMD":"Exist?","Result":"Yes"}')
                    disp('遠端GEF_JSON存在!略過!')
                else
                    disp('查詢命令錯誤!略過!')
                end                
            else
                disp('本地dat檔案不存在!略過!')
            end
            disp('--')
        end
    end
    disp('--')
    %----------------------------------------------------------------------    
    %----------------------------------------------------------------------
    % 停止紀錄命令列的文字，並將之前紀錄的內容寫到檔案中。
    diary off    
    %----------------------------------------------------------------------
    % 倒數計時秒數，請填5的倍數
    countdown_in_second=300;%Target_HTTP_loop_sleep_in_second;
    for k=countdown_in_second:-5:1
        %----------------------------------------------------------
        % 更新GUI文字
        program_info_str_cell{22}=['    倒數',num2str(k),'秒後再次嘗試...'];
        try 
            % 嘗試更新
            set(ui_listbox01_handle,'String', program_info_str_cell)
        catch ME
            % 印出登入異常訊息
            disp(['應該是GUI被關閉吧!return! 錯誤訊息:',ME.message])
            return
        end        
        %--
        drawnow;
        %----------------------------------------------------------
        disp('暫停5秒...')
        pause(5)% 暫停N秒
    end
    %----------------------------------------------------------------------

end   
    