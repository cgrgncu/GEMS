%**************************************************************************
%   Name: GEF_mat_convertor.m v20210315a
%   Copyright:  
%   Author: HsiupoYeh 
%   Version: v20210315a
%   Description: 目前專門給磺嘴山站使用
%**************************************************************************
clear;clc;close all
%--------------------------------------------------------------------------
% 輸出MAT檔案格式
% 建議正式使用時選擇:
% need_Output_GEF_mat=1;
% need_Output_GEF_mat_debug=0;
% need_Output_GEF_mat_missing=1;
% 並且於輸出檔的部分忽略miss檔案，僅交換完整的Day_GEF_mat
need_Output_GEF_mat=1;%0=不要輸出,1=要輸出，交換用的檔案
need_Output_GEF_mat_debug=0;%0=不要輸出,1=要輸出，檢查用的檔案
need_Output_GEF_mat_missing=1;%0=不要輸出,1=要輸出，檔案不齊全的檢查用檔案
%--------------------------------------------------------------------------
% 要轉檔的起始時間
Start_day_str_TaipeiTime='2020-07-29';
Start_day_datenumber_TaipeiTime=datenum(Start_day_str_TaipeiTime, 'yyyy-mm-dd');
%datestr(Start_day_datenumber_TaipeiTime,31)
%--
% 要轉檔的結束時間
End_day_str_TaipeiTime='2021-03-01';
End_day_datenumber_TaipeiTime=datenum(End_day_str_TaipeiTime, 'yyyy-mm-dd')+143/144;
%datestr(End_day_datenumber_TaipeiTime,31)
%--------------------------------------------------------------------------    
% GEF測站名稱
input_site_name='[20200729GEFA]Taiwan-NewTaipeiCity-HuangZuiShan(HUZS)';
% GEF測站註解，磺嘴山站使用Gain=2，僅有v2.4.0.3版以後的軟體轉出的dat檔案數值有正確修正過。
input_description='GrfSyncCommunicator_v2.4.0.3,Gain=2';
%--------------------------------------------------------------------------
% 
%--------------------------------------------------------------------------
% 程式開始
Program_Version_str='v20210315a';
%--
target_day_str=datestr(Start_day_datenumber_TaipeiTime,'yyyy-mm-dd');
temp_data_index=0;
temp_ready_file_count=0;
temp_year_str=datestr(Start_day_datenumber_TaipeiTime,'yyyy');
temp_month_str=datestr(Start_day_datenumber_TaipeiTime,'mm');
temp_day_str=datestr(Start_day_datenumber_TaipeiTime,'dd');
output_mat_file_name=[temp_year_str,temp_month_str,temp_day_str,'.mat'];
disp('轉檔開始...')
for i_datenumber=Start_day_datenumber_TaipeiTime:1/144:End_day_datenumber_TaipeiTime
    %----------------------------------------------------------------------
    %disp(['目標日期=',target_day_str])
    %--
    % 取出日期
    temp_year_str=datestr(i_datenumber,'yyyy');
    temp_month_str=datestr(i_datenumber,'mm');
    temp_day_str=datestr(i_datenumber,'dd');
    temp_hour_str=datestr(i_datenumber,'HH');
    temp_minute_str=datestr(i_datenumber,'MM');
    temp_second_str=datestr(i_datenumber,'SS');
    %--
    % 不同日期將清空重整
    if strcmp(target_day_str,datestr(i_datenumber,'yyyy-mm-dd'))==1
        %disp('日期相同')
    else
        %disp('日期不同!變更為新日期')
        target_day_str=datestr(i_datenumber,'yyyy-mm-dd');
        temp_data_index=0;
        temp_ready_file_count=0;
        output_mat_file_name=[temp_year_str,temp_month_str,temp_day_str,'.mat'];
        clear Day_GEF_mat_debug;
    end
    %--   
    % 準備檔案
    input_file_folder=['..\..\..\Converted\Y',temp_year_str,'\M',temp_month_str,'\D',temp_day_str];
    input_file_name=[temp_year_str,'_',temp_month_str,'_',temp_day_str,'_',temp_hour_str,'_',temp_minute_str,'_',temp_second_str,'.dat'];
    % 讀GEF_dat檔案
    temp_data=read_GEF_dat_to_GEF_mat_v20210315a(input_site_name,input_file_folder,input_file_name,input_description);   
    % 依序存入結構體中
    temp_data_index=temp_data_index+1;
	Day_GEF_mat_debug(temp_data_index,1)=temp_data;
    % 確認讀取狀況，若有缺失則改變mat儲存檔名
    if isempty(temp_data.ErrorMsg)
        %disp('讀檔成功')
        temp_ready_file_count=temp_ready_file_count+1;
    else
        disp(['GEF_mat_convertor:',temp_data.ErrorMsg,'檔名:',input_file_name])
        %output_mat_file_name=[temp_year_str,temp_month_str,temp_day_str,'_miss.mat'];        
    end
    %--
    % 檔案數量=144時存檔，可存「Day_GEF_mat_debug」與「Day_GEF_mat」
    if temp_data_index==144 && temp_ready_file_count==144        
        if need_Output_GEF_mat_debug==1%0=不要輸出,1=要輸出，檢查用的檔案
            output_mat_file_name=[temp_year_str,temp_month_str,temp_day_str,'_debug.mat'];
            output_mat_file_folder=['Output\',temp_year_str,'\',temp_month_str];
            disp(['存檔:',output_mat_file_folder,'\',output_mat_file_name])
            if (exist(output_mat_file_folder,'dir')~=7)
            %disp(['資料夾不存在，新建立!'])
            mkdir(output_mat_file_folder)
            end        
            save([output_mat_file_folder,'\',output_mat_file_name],'Day_GEF_mat_debug')
        end
        if need_Output_GEF_mat==1;%0=不要輸出,1=要輸出，交換用的檔案
            Day_GEF_mat.Version=Day_GEF_mat_debug(1).Version;
            Day_GEF_mat.Format=Day_GEF_mat_debug(1).Format;
            Day_GEF_mat.SiteName=Day_GEF_mat_debug(1).SiteName;
            Day_GEF_mat.Description=Day_GEF_mat_debug(1).Description;
            Day_GEF_mat.StartTime_TaipeiTime_str=Day_GEF_mat_debug(1).StartTime_TaipeiTime_str;
            Day_GEF_mat.StartTime_TaipeiTime_datenumber=Day_GEF_mat_debug(1).StartTime_TaipeiTime_datenumber;
            Day_GEF_mat.StartTime_UTC_datenumber=Day_GEF_mat_debug(1).StartTime_UTC_datenumber;
            Day_GEF_mat.SampleRate=Day_GEF_mat_debug(1).SampleRate;
            Day_GEF_mat.DataHeader=Day_GEF_mat_debug(1).DataHeader;
            temp_arrange_array=[Day_GEF_mat_debug(:).Data];
            Day_GEF_mat.Data=reshape(temp_arrange_array(:,[1:2:end,2:2:end]),[],2);
            Day_GEF_mat.CH01_nan_data_count=sum([Day_GEF_mat_debug(:).CH01_nan_data_count]);
            Day_GEF_mat.CH02_nan_data_count=sum([Day_GEF_mat_debug(:).CH02_nan_data_count]);
            Day_GEF_mat.ErrorMsg=Day_GEF_mat_debug(1).ErrorMsg;
            %--
            output_mat_file_name=[temp_year_str,temp_month_str,temp_day_str,'.mat'];
            output_mat_file_folder=['Output\',temp_year_str,'\',temp_month_str];
            disp(['存檔:',output_mat_file_folder,'\',output_mat_file_name])
            if (exist(output_mat_file_folder,'dir')~=7)
                %disp(['資料夾不存在，新建立!'])
                mkdir(output_mat_file_folder)
            end        
            save([output_mat_file_folder,'\',output_mat_file_name],'Day_GEF_mat')            
        end
    elseif temp_data_index==144 && temp_ready_file_count<144 && temp_ready_file_count>0      
        if need_Output_GEF_mat_missing==1;%0=不要輸出,1=要輸出，檔案不齊全的檢查用檔案
            output_mat_file_name=[temp_year_str,temp_month_str,temp_day_str,'_miss.mat'];
            output_mat_file_folder=['Output\',temp_year_str,'\',temp_month_str];
            disp(['存檔:',output_mat_file_folder,'\',output_mat_file_name])
            if (exist(output_mat_file_folder,'dir')~=7)
                %disp(['資料夾不存在，新建立!'])
                mkdir(output_mat_file_folder)
            end        
            save([output_mat_file_folder,'\',output_mat_file_name],'Day_GEF_mat_debug')
        end
    end
    %----------------------------------------------------------------------
end
disp('轉檔結束!')
    
    

    