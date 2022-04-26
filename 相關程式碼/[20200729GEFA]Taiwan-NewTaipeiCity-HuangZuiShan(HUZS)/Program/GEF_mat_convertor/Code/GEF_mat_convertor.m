%**************************************************************************
%   Name: GEF_mat_convertor.m v20210315a
%   Copyright:  
%   Author: HsiupoYeh 
%   Version: v20210315a
%   Description: �ثe�M�����D�L�s���ϥ�
%**************************************************************************
clear;clc;close all
%--------------------------------------------------------------------------
% ��XMAT�ɮ׮榡
% ��ĳ�����ϥήɿ��:
% need_Output_GEF_mat=1;
% need_Output_GEF_mat_debug=0;
% need_Output_GEF_mat_missing=1;
% �åB���X�ɪ���������miss�ɮסA�ȥ洫���㪺Day_GEF_mat
need_Output_GEF_mat=1;%0=���n��X,1=�n��X�A�洫�Ϊ��ɮ�
need_Output_GEF_mat_debug=0;%0=���n��X,1=�n��X�A�ˬd�Ϊ��ɮ�
need_Output_GEF_mat_missing=1;%0=���n��X,1=�n��X�A�ɮפ��������ˬd���ɮ�
%--------------------------------------------------------------------------
% �n���ɪ��_�l�ɶ�
Start_day_str_TaipeiTime='2020-07-29';
Start_day_datenumber_TaipeiTime=datenum(Start_day_str_TaipeiTime, 'yyyy-mm-dd');
%datestr(Start_day_datenumber_TaipeiTime,31)
%--
% �n���ɪ������ɶ�
End_day_str_TaipeiTime='2021-03-01';
End_day_datenumber_TaipeiTime=datenum(End_day_str_TaipeiTime, 'yyyy-mm-dd')+143/144;
%datestr(End_day_datenumber_TaipeiTime,31)
%--------------------------------------------------------------------------    
% GEF�����W��
input_site_name='[20200729GEFA]Taiwan-NewTaipeiCity-HuangZuiShan(HUZS)';
% GEF�������ѡA�D�L�s���ϥ�Gain=2�A�Ȧ�v2.4.0.3���H�᪺�n����X��dat�ɮ׼ƭȦ����T�ץ��L�C
input_description='GrfSyncCommunicator_v2.4.0.3,Gain=2';
%--------------------------------------------------------------------------
% 
%--------------------------------------------------------------------------
% �{���}�l
Program_Version_str='v20210315a';
%--
target_day_str=datestr(Start_day_datenumber_TaipeiTime,'yyyy-mm-dd');
temp_data_index=0;
temp_ready_file_count=0;
temp_year_str=datestr(Start_day_datenumber_TaipeiTime,'yyyy');
temp_month_str=datestr(Start_day_datenumber_TaipeiTime,'mm');
temp_day_str=datestr(Start_day_datenumber_TaipeiTime,'dd');
output_mat_file_name=[temp_year_str,temp_month_str,temp_day_str,'.mat'];
disp('���ɶ}�l...')
for i_datenumber=Start_day_datenumber_TaipeiTime:1/144:End_day_datenumber_TaipeiTime
    %----------------------------------------------------------------------
    %disp(['�ؼФ��=',target_day_str])
    %--
    % ���X���
    temp_year_str=datestr(i_datenumber,'yyyy');
    temp_month_str=datestr(i_datenumber,'mm');
    temp_day_str=datestr(i_datenumber,'dd');
    temp_hour_str=datestr(i_datenumber,'HH');
    temp_minute_str=datestr(i_datenumber,'MM');
    temp_second_str=datestr(i_datenumber,'SS');
    %--
    % ���P����N�M�ŭ���
    if strcmp(target_day_str,datestr(i_datenumber,'yyyy-mm-dd'))==1
        %disp('����ۦP')
    else
        %disp('������P!�ܧ󬰷s���')
        target_day_str=datestr(i_datenumber,'yyyy-mm-dd');
        temp_data_index=0;
        temp_ready_file_count=0;
        output_mat_file_name=[temp_year_str,temp_month_str,temp_day_str,'.mat'];
        clear Day_GEF_mat_debug;
    end
    %--   
    % �ǳ��ɮ�
    input_file_folder=['..\..\..\Converted\Y',temp_year_str,'\M',temp_month_str,'\D',temp_day_str];
    input_file_name=[temp_year_str,'_',temp_month_str,'_',temp_day_str,'_',temp_hour_str,'_',temp_minute_str,'_',temp_second_str,'.dat'];
    % ŪGEF_dat�ɮ�
    temp_data=read_GEF_dat_to_GEF_mat_v20210315a(input_site_name,input_file_folder,input_file_name,input_description);   
    % �̧Ǧs�J���c�餤
    temp_data_index=temp_data_index+1;
	Day_GEF_mat_debug(temp_data_index,1)=temp_data;
    % �T�{Ū�����p�A�Y���ʥ��h����mat�x�s�ɦW
    if isempty(temp_data.ErrorMsg)
        %disp('Ū�ɦ��\')
        temp_ready_file_count=temp_ready_file_count+1;
    else
        disp(['GEF_mat_convertor:',temp_data.ErrorMsg,'�ɦW:',input_file_name])
        %output_mat_file_name=[temp_year_str,temp_month_str,temp_day_str,'_miss.mat'];        
    end
    %--
    % �ɮ׼ƶq=144�ɦs�ɡA�i�s�uDay_GEF_mat_debug�v�P�uDay_GEF_mat�v
    if temp_data_index==144 && temp_ready_file_count==144        
        if need_Output_GEF_mat_debug==1%0=���n��X,1=�n��X�A�ˬd�Ϊ��ɮ�
            output_mat_file_name=[temp_year_str,temp_month_str,temp_day_str,'_debug.mat'];
            output_mat_file_folder=['Output\',temp_year_str,'\',temp_month_str];
            disp(['�s��:',output_mat_file_folder,'\',output_mat_file_name])
            if (exist(output_mat_file_folder,'dir')~=7)
            %disp(['��Ƨ����s�b�A�s�إ�!'])
            mkdir(output_mat_file_folder)
            end        
            save([output_mat_file_folder,'\',output_mat_file_name],'Day_GEF_mat_debug')
        end
        if need_Output_GEF_mat==1;%0=���n��X,1=�n��X�A�洫�Ϊ��ɮ�
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
            disp(['�s��:',output_mat_file_folder,'\',output_mat_file_name])
            if (exist(output_mat_file_folder,'dir')~=7)
                %disp(['��Ƨ����s�b�A�s�إ�!'])
                mkdir(output_mat_file_folder)
            end        
            save([output_mat_file_folder,'\',output_mat_file_name],'Day_GEF_mat')            
        end
    elseif temp_data_index==144 && temp_ready_file_count<144 && temp_ready_file_count>0      
        if need_Output_GEF_mat_missing==1;%0=���n��X,1=�n��X�A�ɮפ��������ˬd���ɮ�
            output_mat_file_name=[temp_year_str,temp_month_str,temp_day_str,'_miss.mat'];
            output_mat_file_folder=['Output\',temp_year_str,'\',temp_month_str];
            disp(['�s��:',output_mat_file_folder,'\',output_mat_file_name])
            if (exist(output_mat_file_folder,'dir')~=7)
                %disp(['��Ƨ����s�b�A�s�إ�!'])
                mkdir(output_mat_file_folder)
            end        
            save([output_mat_file_folder,'\',output_mat_file_name],'Day_GEF_mat_debug')
        end
    end
    %----------------------------------------------------------------------
end
disp('���ɵ���!')
    
    

    