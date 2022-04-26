%**************************************************************************
%   Name: GEF_dat_to_GEF_JSON.m v20200817a
%   Copyright:  
%   Author: HsiupoYeh 
%   Version: v20200817a
%   Description: 台灣地電場觀測網(GEFN)觀測站使用GRF2.0儀器，搭配隨附軟體
%                GrfSyncCommunicator_v2.2.0.1版本，所轉出的dat檔案，被我定義為
%                GEF_dat，目前無版本之分，紀錄資料單位為[V]，目前規定該設備存檔檔名為起始時間。
%                本程式利用副程式:read_GEF_dat_to_GEF_mat.m將資料再寫成GEF_JSON格式。             
%   呼叫範例:Result=GEF_dat_to_GEF_JSON('[20200729GEFA]Taiwan-NewTaipeiCity-HuangZuiShan(HUZS)','2020_07_29_10_30_00.dat','')
%**************************************************************************
function Result=GEF_dat_to_GEF_JSON(input_site_name,input_file_name,input_description,output_file_name)
% clear;clc;close all
% input_site_name='[20200729GEFA]Taiwan-NewTaipeiCity-HuangZuiShan(HUZS)';
% input_file_name='2020_08_02_00_00_00.dat';
% input_description='';
% output_file_name='2020_08_02_00_00_00.json';
    %--
    % 程式版本
    Program_Version='v20200817a';
    %--
    % 讀檔案
    temp_GEF_mat=read_GEF_dat_to_GEF_mat(input_site_name,input_file_name,input_description);
    if (temp_GEF_mat.Return_code~=0)
        disp('錯誤!讀取GEF_mat檔案失敗!');
        Result.Return_code=-1;
        Result.ErrorMsg='錯誤!讀取GEF_mat檔案失敗!';
        return
    end
    %--
    % 寫檔案
    f1=fopen(output_file_name,'w');
    if f1<0
        disp('錯誤!開啟檔案失敗!');
        Result.Return_code=-1;
        Result.ErrorMsg='錯誤!開啟檔案失敗!';
        return
    end
    % {
    fprintf(f1,'{\n');
    % Version
    fprintf(f1,'\t"Version":"%s",\n',Program_Version);
    % Format
    fprintf(f1,'\t"Format":"GEF_JSON",\n');
    % SiteName
    fprintf(f1,'\t"SiteName":"%s",\n',temp_GEF_mat.SiteName);
    % Description
    fprintf(f1,'\t"Description":"%s",\n',temp_GEF_mat.Description);
    % StartTime_TaipeiTime
    fprintf(f1,'\t"StartTime_TaipeiTime":"%s",\n',temp_GEF_mat.StartTime_TaipeiTime_str);
    % SampleRate
    fprintf(f1,'\t"SampleRate":"%d",\n',temp_GEF_mat.SampleRate);
    % CH01_delta_AC_mV
    fprintf(f1,'\t"CH01_delta_AC_mV":[\n');
    temp_one_channel_data=temp_GEF_mat.Data(:,1);
    temp_one_channel_data_count=length(temp_one_channel_data);
    for i=1:temp_one_channel_data_count
        if (i==temp_one_channel_data_count)
            if mod(i,10)==1
                if isnan(temp_one_channel_data(i))
                    fprintf(f1,'\tnull\n\t]');
                else
                    fprintf(f1,'\t%.3f\n\t]',temp_one_channel_data(i));
                end
            else
                if isnan(temp_one_channel_data(i))
                    fprintf(f1,'null\n\t]');
                else
                    fprintf(f1,'%.3f\n\t]',temp_one_channel_data(i));
                end
            end
        elseif mod(i,10)==1
            if isnan(temp_one_channel_data(i))
                fprintf(f1,'\tnull,');
            else
                fprintf(f1,'\t%.3f,',temp_one_channel_data(i));
            end
        elseif mod(i,10)==0
            if isnan(temp_one_channel_data(i))
                fprintf(f1,'null,\n');
            else
                fprintf(f1,'%.3f,\n',temp_one_channel_data(i));
            end
        else
            if isnan(temp_one_channel_data(i))
                fprintf(f1,'null,');
            else
                fprintf(f1,'%.3f,',temp_one_channel_data(i));
            end
        end
    end
    fprintf(f1,',\n');
    % CH02_delta_BC_mV
    fprintf(f1,'\t"CH02_delta_BC_mV":[\n');
    temp_one_channel_data=temp_GEF_mat.Data(:,2);
    temp_one_channel_data_count=length(temp_one_channel_data);
    for i=1:temp_one_channel_data_count
        if (i==temp_one_channel_data_count)
            if mod(i,10)==1
                if isnan(temp_one_channel_data(i))
                    fprintf(f1,'\tnull\n\t]');
                else
                    fprintf(f1,'\t%.3f\n\t]',temp_one_channel_data(i));
                end
            else
                if isnan(temp_one_channel_data(i))
                    fprintf(f1,'null\n\t]');
                else
                    fprintf(f1,'%.3f\n\t]',temp_one_channel_data(i));
                end
            end
        elseif mod(i,10)==1
            if isnan(temp_one_channel_data(i))
                fprintf(f1,'\tnull,');
            else
                fprintf(f1,'\t%.3f,',temp_one_channel_data(i));
            end
        elseif mod(i,10)==0
            if isnan(temp_one_channel_data(i))
                fprintf(f1,'null,\n');
            else
                fprintf(f1,'%.3f,\n',temp_one_channel_data(i));
            end
        else
            if isnan(temp_one_channel_data(i))
                fprintf(f1,'null,');
            else
                fprintf(f1,'%.3f,',temp_one_channel_data(i));
            end
        end
    end
    fprintf(f1,'\n');
    % }
    fprintf(f1,'}\n');    
    % 
    fclose(f1);
    %--
    % 正常完成!回傳結果碼
	Result.Return_code=0;%0=正常，-1=錯誤。
    Result.ErrorMsg='';
    return
    %----------------------------------------------------------------------
