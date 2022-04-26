%**************************************************************************
%   Name: GEF_dat_to_GEF_JSON_1Day_0p1Hz.m v20200825a
%   Copyright:  
%   Author: HsiupoYeh 
%   Version: v20200825a
%   Description: 台灣地電場觀測網(GEFN)觀測站使用GRF2.0儀器，搭配隨附軟體
%                GrfSyncCommunicator_v2.2.0.1版本，所轉出的dat檔案，被我定義為
%                GEF_dat，目前無版本之分，紀錄資料單位為[V]，目前規定該設備存檔檔名為起始時間。
%                本程式利用副程式:read_GEF_dat_to_GEF_mat.m將資料再寫成GEF_JSON格式，此為15點平均為一天的版本。             
%   呼叫範例:Result=GEF_dat_to_GEF_JSON_1Day_0p1Hz('[20200729GEFA]Taiwan-NewTaipeiCity-HuangZuiShan(HUZS)',{'2020_08_02_00_00_00.dat';'2020_08_02_00_10_00.dat'},'','2020_08_02.json')
%**************************************************************************
function Result=GEF_dat_to_GEF_JSON_1Day_0p1Hz(input_site_name,input_file_folder,input_file_name_cell,input_description,output_file_name)
% clear;clc;close all
% input_site_name='[20200729GEFA]Taiwan-NewTaipeiCity-HuangZuiShan(HUZS)';
% 
% temp_dir_result=dir(['*.dat']);
% temp_dir_result={temp_dir_result.name}';
% input_file_name_cell=temp_dir_result;
% input_description='';
% output_file_name='2020_08_02_00_00_00.json';
    %--
    % 程式版本
    Program_Version='v20200825a';
    %--
    for i=1:length(input_file_name_cell)
    % 讀檔案
        temp_GEF_mat{i,1}=read_GEF_dat_to_GEF_mat(input_site_name,[input_file_folder,input_file_name_cell{i}],input_description);
        if (temp_GEF_mat{i,1}.Return_code~=0)
            disp('錯誤!讀取GEF_mat檔案失敗!');
            Result.Return_code=-1;
            Result.ErrorMsg='錯誤!讀取GEF_mat檔案失敗!';
            return
        else
            temp_GEF_mat{i,1}.SampleRate=0.1;
            temp_CH01_data_15Hz=temp_GEF_mat{i,1}.Data(:,1);
            temp_CH02_data_15Hz=temp_GEF_mat{i,1}.Data(:,2);
            temp_CH01_data_0p1Hz=mean(reshape(temp_CH01_data_15Hz,150,[]))';
            temp_CH02_data_0p1Hz=mean(reshape(temp_CH02_data_15Hz,150,[]))';
            temp_GEF_mat{i,1}.Data=[temp_CH01_data_0p1Hz,temp_CH02_data_0p1Hz];
        end
    end
    temp_data=[temp_GEF_mat{:}]';
    temp_data=[temp_data.Data,];
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
    fprintf(f1,'\t"SiteName":"%s",\n',temp_GEF_mat{1}.SiteName);
    % Description
    fprintf(f1,'\t"Description":"%s",\n',temp_GEF_mat{1}.Description);
    % StartTime_TaipeiTime
    fprintf(f1,'\t"StartTime_TaipeiTime":"%s",\n',temp_GEF_mat{1}.StartTime_TaipeiTime_str);
    % SampleRate
    fprintf(f1,'\t"SampleRate":"%d",\n',temp_GEF_mat{1}.SampleRate);
    % CH01_delta_AC_mV
    fprintf(f1,'\t"CH01_delta_AC_mV":[\n');    
    temp_one_channel_data=reshape(temp_data(:,1:2:end),1,[])';
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
    temp_one_channel_data=reshape(temp_data(:,2:2:end),1,[])';
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
