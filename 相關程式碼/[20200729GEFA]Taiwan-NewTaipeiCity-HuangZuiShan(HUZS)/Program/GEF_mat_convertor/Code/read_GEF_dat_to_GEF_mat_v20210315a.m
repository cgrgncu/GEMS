%**************************************************************************
%   Name: read_GEF_dat_to_GEF_mat_v20210315a.m v20210315a
%   Copyright:  
%   Author: HsiupoYeh 
%   Version: v20210315a
%   Description: 台灣地電場觀測網(GEFN)觀測站使用GRF2.0儀器，搭配隨附軟體
%                GrfSyncCommunicator_v2.4.0.3版本，所轉出的dat檔案，被我定義為
%                GEF_dat，目前無版本之分，紀錄資料單位為[V]，目前規定該設備存檔檔名為起始時間。
%                轉檔存成我定義的GEF_mat格式，版本為「v20210315a」。
%                轉檔過程中會記錄錯誤與資料遺失等資訊。                
%   呼叫範例:read_GEF_dat_to_GEF_mat('[20200729GEFA]Taiwan-NewTaipeiCity-HuangZuiShan(HUZS)','[20200729GEFA]Taiwan-NewTaipeiCity-HuangZuiShan(HUZS)\Converted\Y2020\M08\D02','2020_08_02_00_00_00.dat','GrfSyncCommunicator_v2.4.0.3,Gain=2')
%**************************************************************************
function GEF_mat=read_GEF_dat_to_GEF_mat_v20210315a(input_site_name,input_file_folder,input_file_name,input_description)
% clear;clc;close all
% input_site_name='[20200729GEFA]Taiwan-NewTaipeiCity-HuangZuiShan(HUZS)';
% input_file_folder='Converted\Y2020\M08\D02';
% input_file_name='2020_08_02_00_00_00.dat';
% input_description='';

    %----------------------------------------------------------------------
    % GEF_mat版本
    GEF_mat.Version='v20210315a';
    % GEF_mat格式
    GEF_mat.Format='GEF_mat';
    % 測站名稱
    GEF_mat.SiteName=input_site_name;
    % 測站描述
    GEF_mat.Description=input_description;
    % 紀錄起始時間(台北時間)，使用MATLAB datenumber。
    GEF_mat.StartTime_TaipeiTime_str=[...
                                    input_file_name(1:4),'-',...
                                    input_file_name(6:7),'-',...
                                    input_file_name(9:10),' ',...
                                    input_file_name(12:13),':',...
                                    input_file_name(15:16),':',...
                                    input_file_name(18:19)];
    % 紀錄起始時間(台北時間)，使用MATLAB datenumber。
    GEF_mat.StartTime_TaipeiTime_datenumber=datenum(...
                                    str2num(input_file_name(1:4)),...
                                    str2num(input_file_name(6:7)),...
                                    str2num(input_file_name(9:10)),...
                                    str2num(input_file_name(12:13)),...
                                    str2num(input_file_name(15:16)),...
                                    str2num(input_file_name(18:19)));	
	% 紀錄起始時間(UTC時間)，使用MATLAB datenumber。
    GEF_mat.StartTime_UTC_datenumber=GEF_mat.StartTime_TaipeiTime_datenumber-(8/24);
    % 其他輸出
    GEF_mat.SampleRate=[];
    GEF_mat.DataHeader=[];
    GEF_mat.Data=[];
    GEF_mat.CH01_nan_data_count=[];
    GEF_mat.CH02_nan_data_count=[];
    %----------------------------------------------------------------------
    % 開啟檔案
    f1=fopen([input_file_folder,'\',input_file_name],'r');
    if f1<0
        disp('read_GEF_dat_to_GEF_mat_v20210315a:錯誤!開啟檔案失敗!');
        GEF_mat.ErrorMsg='錯誤!開啟檔案失敗!';
        return
    end
    % 讀取檔頭
    temp_header_data=fread(f1,50,'short','ieee-le');
    % disp(['紀錄起始時間-年:',num2str(temp_header_data(1))])
    % disp(['紀錄起始時間-月:',num2str(temp_header_data(2))])
    % disp(['紀錄起始時間-日:',num2str(temp_header_data(3))])
    % disp(['紀錄起始時間-時:',num2str(temp_header_data(4))])
    % disp(['紀錄起始時間-分:',num2str(temp_header_data(5))])
    % disp(['紀錄起始時間-秒:',num2str(temp_header_data(6))])
    % disp(['紀錄起始時間(台北時間):',num2str(temp_header_data(1)),'-',num2str(temp_header_data(2)),'-',num2str(temp_header_data(3)),' ',num2str(temp_header_data(4)),':',num2str(temp_header_data(5)),':',num2str(temp_header_data(6))])
    temp_StartTime_TaipeiTime_datenumber=datenum(...
                                    temp_header_data(1),...
                                    temp_header_data(2),...
                                    temp_header_data(3),...
                                    temp_header_data(4),...
                                    temp_header_data(5),...
                                    temp_header_data(6));
    if (GEF_mat.StartTime_TaipeiTime_datenumber==temp_StartTime_TaipeiTime_datenumber)
        %disp('起始時間正確!')
    else
        disp('read_GEF_dat_to_GEF_mat_v20210315a:錯誤!起始時間錯誤!')
        GEF_mat.ErrorMsg='錯誤!起始時間錯誤!';
        return
    end
    %disp(['取樣率[Hz]:',num2str(temp_header_data(7))])
    GEF_mat.SampleRate=temp_header_data(7);
    %disp(['Channel Options:',num2str(temp_header_data(8))])
    %--
    % 讀取資料(時間部分)
    temp_data=fread(f1,inf,'int',16,'ieee-le');
    % 分析時間部分資料，簡單驗證:
    % 時間差距是:67,66,67,67,66,67,67....
    % 可以挑出來檢查數值是否正確
    temp_diff_result=diff(temp_data);                
    check_66_value_count=sum(temp_diff_result(2:3:end)==66);
    check_67_value_count=sum(temp_diff_result==67);
    if (check_66_value_count==3000)&&(check_67_value_count==5999)
        %disp('時間間隔正常!')
    else
        disp('read_GEF_dat_to_GEF_mat_v20210315a:錯誤!時間間隔異常!')
        GEF_mat.ErrorMsg='錯誤!時間間隔異常!';
        return
    end
    %--
    % 讀取資料(頻道資料部分)
    fseek(f1, 104, 'bof');
    temp_data=fread(f1,[4,inf],'4*float',4,'ieee-le')';
    % 頻道資料(本應用只取用前兩個直行的資料，即CH01、CH02)
    GEF_mat.DataHeader={'CH01(delta_AC)[V]','CH02(delta_BC)[V]'};
    GEF_mat.Data=temp_data(:,1:2);
    % 分析頻道資料
    % 資料以float方式儲存，存在NaN，檢查NaN數量，代表機器遺失資料數量
    GEF_mat.CH01_nan_data_count=sum(isnan(temp_data(:,1)));
    GEF_mat.CH02_nan_data_count=sum(isnan(temp_data(:,2)));
    fclose(f1);
    GEF_mat.ErrorMsg='';
    return
    %----------------------------------------------------------------------
