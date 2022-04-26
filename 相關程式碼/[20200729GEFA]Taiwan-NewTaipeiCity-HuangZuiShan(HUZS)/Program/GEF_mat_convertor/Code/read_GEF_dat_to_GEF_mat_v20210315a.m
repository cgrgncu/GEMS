%**************************************************************************
%   Name: read_GEF_dat_to_GEF_mat_v20210315a.m v20210315a
%   Copyright:  
%   Author: HsiupoYeh 
%   Version: v20210315a
%   Description: �x�W�a�q���[����(GEFN)�[�����ϥ�GRF2.0�����A�f�t�H���n��
%                GrfSyncCommunicator_v2.4.0.3�����A����X��dat�ɮסA�Q�کw�q��
%                GEF_dat�A�ثe�L���������A������Ƴ�쬰[V]�A�ثe�W�w�ӳ]�Ʀs���ɦW���_�l�ɶ��C
%                ���ɦs���کw�q��GEF_mat�榡�A�������uv20210315a�v�C
%                ���ɹL�{���|�O�����~�P��ƿ򥢵���T�C                
%   �I�s�d��:read_GEF_dat_to_GEF_mat('[20200729GEFA]Taiwan-NewTaipeiCity-HuangZuiShan(HUZS)','[20200729GEFA]Taiwan-NewTaipeiCity-HuangZuiShan(HUZS)\Converted\Y2020\M08\D02','2020_08_02_00_00_00.dat','GrfSyncCommunicator_v2.4.0.3,Gain=2')
%**************************************************************************
function GEF_mat=read_GEF_dat_to_GEF_mat_v20210315a(input_site_name,input_file_folder,input_file_name,input_description)
% clear;clc;close all
% input_site_name='[20200729GEFA]Taiwan-NewTaipeiCity-HuangZuiShan(HUZS)';
% input_file_folder='Converted\Y2020\M08\D02';
% input_file_name='2020_08_02_00_00_00.dat';
% input_description='';

    %----------------------------------------------------------------------
    % GEF_mat����
    GEF_mat.Version='v20210315a';
    % GEF_mat�榡
    GEF_mat.Format='GEF_mat';
    % �����W��
    GEF_mat.SiteName=input_site_name;
    % �����y�z
    GEF_mat.Description=input_description;
    % �����_�l�ɶ�(�x�_�ɶ�)�A�ϥ�MATLAB datenumber�C
    GEF_mat.StartTime_TaipeiTime_str=[...
                                    input_file_name(1:4),'-',...
                                    input_file_name(6:7),'-',...
                                    input_file_name(9:10),' ',...
                                    input_file_name(12:13),':',...
                                    input_file_name(15:16),':',...
                                    input_file_name(18:19)];
    % �����_�l�ɶ�(�x�_�ɶ�)�A�ϥ�MATLAB datenumber�C
    GEF_mat.StartTime_TaipeiTime_datenumber=datenum(...
                                    str2num(input_file_name(1:4)),...
                                    str2num(input_file_name(6:7)),...
                                    str2num(input_file_name(9:10)),...
                                    str2num(input_file_name(12:13)),...
                                    str2num(input_file_name(15:16)),...
                                    str2num(input_file_name(18:19)));	
	% �����_�l�ɶ�(UTC�ɶ�)�A�ϥ�MATLAB datenumber�C
    GEF_mat.StartTime_UTC_datenumber=GEF_mat.StartTime_TaipeiTime_datenumber-(8/24);
    % ��L��X
    GEF_mat.SampleRate=[];
    GEF_mat.DataHeader=[];
    GEF_mat.Data=[];
    GEF_mat.CH01_nan_data_count=[];
    GEF_mat.CH02_nan_data_count=[];
    %----------------------------------------------------------------------
    % �}���ɮ�
    f1=fopen([input_file_folder,'\',input_file_name],'r');
    if f1<0
        disp('read_GEF_dat_to_GEF_mat_v20210315a:���~!�}���ɮץ���!');
        GEF_mat.ErrorMsg='���~!�}���ɮץ���!';
        return
    end
    % Ū�����Y
    temp_header_data=fread(f1,50,'short','ieee-le');
    % disp(['�����_�l�ɶ�-�~:',num2str(temp_header_data(1))])
    % disp(['�����_�l�ɶ�-��:',num2str(temp_header_data(2))])
    % disp(['�����_�l�ɶ�-��:',num2str(temp_header_data(3))])
    % disp(['�����_�l�ɶ�-��:',num2str(temp_header_data(4))])
    % disp(['�����_�l�ɶ�-��:',num2str(temp_header_data(5))])
    % disp(['�����_�l�ɶ�-��:',num2str(temp_header_data(6))])
    % disp(['�����_�l�ɶ�(�x�_�ɶ�):',num2str(temp_header_data(1)),'-',num2str(temp_header_data(2)),'-',num2str(temp_header_data(3)),' ',num2str(temp_header_data(4)),':',num2str(temp_header_data(5)),':',num2str(temp_header_data(6))])
    temp_StartTime_TaipeiTime_datenumber=datenum(...
                                    temp_header_data(1),...
                                    temp_header_data(2),...
                                    temp_header_data(3),...
                                    temp_header_data(4),...
                                    temp_header_data(5),...
                                    temp_header_data(6));
    if (GEF_mat.StartTime_TaipeiTime_datenumber==temp_StartTime_TaipeiTime_datenumber)
        %disp('�_�l�ɶ����T!')
    else
        disp('read_GEF_dat_to_GEF_mat_v20210315a:���~!�_�l�ɶ����~!')
        GEF_mat.ErrorMsg='���~!�_�l�ɶ����~!';
        return
    end
    %disp(['���˲v[Hz]:',num2str(temp_header_data(7))])
    GEF_mat.SampleRate=temp_header_data(7);
    %disp(['Channel Options:',num2str(temp_header_data(8))])
    %--
    % Ū�����(�ɶ�����)
    temp_data=fread(f1,inf,'int',16,'ieee-le');
    % ���R�ɶ�������ơA²������:
    % �ɶ��t�Z�O:67,66,67,67,66,67,67....
    % �i�H�D�X���ˬd�ƭȬO�_���T
    temp_diff_result=diff(temp_data);                
    check_66_value_count=sum(temp_diff_result(2:3:end)==66);
    check_67_value_count=sum(temp_diff_result==67);
    if (check_66_value_count==3000)&&(check_67_value_count==5999)
        %disp('�ɶ����j���`!')
    else
        disp('read_GEF_dat_to_GEF_mat_v20210315a:���~!�ɶ����j���`!')
        GEF_mat.ErrorMsg='���~!�ɶ����j���`!';
        return
    end
    %--
    % Ū�����(�W�D��Ƴ���)
    fseek(f1, 104, 'bof');
    temp_data=fread(f1,[4,inf],'4*float',4,'ieee-le')';
    % �W�D���(�����Υu���Ϋe��Ӫ��檺��ơA�YCH01�BCH02)
    GEF_mat.DataHeader={'CH01(delta_AC)[V]','CH02(delta_BC)[V]'};
    GEF_mat.Data=temp_data(:,1:2);
    % ���R�W�D���
    % ��ƥHfloat�覡�x�s�A�s�bNaN�A�ˬdNaN�ƶq�A�N������򥢸�Ƽƶq
    GEF_mat.CH01_nan_data_count=sum(isnan(temp_data(:,1)));
    GEF_mat.CH02_nan_data_count=sum(isnan(temp_data(:,2)));
    fclose(f1);
    GEF_mat.ErrorMsg='';
    return
    %----------------------------------------------------------------------
