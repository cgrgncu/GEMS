%**************************************************************************
%   Name: HTTP_Upload_GEF_dat_and_GEF_JSON.m v20201019a
%   Copyright:  
%   Author: HsiupoYeh 
%   Version: v20201019a
%   Description: �ʱ���Ƨ����O�_���ݭn�W�ǩ����ɪ�dat�ɮסA�Y���h�W�ǡC
%                ���PMATLAB�������Ϥ���m�i��n��ʽվ�C
%  �B��ݨD�~���ɮ�:HTTP_Upload_GEF_dat_and_GEF_JSON_pushbutton_callback.m
%                  get_cgrg_logo_image.m
%                  get_cgrg_long_logo_image.m
%                  ini2struct_ansi.m
%                  curl.exe
%                  libcurl.dll
%**************************************************************************
clear;clc;close all
Program_Version_str='v20201019a';
    %==========================================================================
    % ����uitable���A�Ӯi�ܤ��e
    %--------------------------------------------------------------------------
    % �إ�UI�Ϊ�figure�ó]�w�����i���A�ؤo�]�w640x660
    ui_figure_handle = figure('OuterPosition',[1,1,625,680],'Visible','off');
    %--
    % �]�w��Lfigure�Ѽ�
    %--
    % ���i����figure�j�p�C
    set(ui_figure_handle,'Resize','off')
    % ���ÿ��C
    set(ui_figure_handle,'MenuBar','none')
    % ���äu��C
    set(ui_figure_handle,'ToolBar','none')
    % ����figure�Ʀr
    set(ui_figure_handle,'NumberTitle','off')
    % �]�wfigure�W��
    set(ui_figure_handle,'Name','HTTP_Upload_GEF_dat_and_GEF_JSON')
    %--
    set(ui_figure_handle,'DeleteFcn','disp(''�ϥΪ������{��!'');return;')
    % ���ʨ�ù�����
    movegui(ui_figure_handle,'center')
    % �אּ�i��
    set(gcf,'Visible','on');
    %--
    % �G�N��Ϥ����e�g���Ƥ��A��ֹ��ɸ��|���]�p�C
    cgrg_logo_image=get_cgrg_logo_image();
    imwrite(cgrg_logo_image,'icon.png')
    %--
    % �]�wicon
    javaFrame=get(handle(ui_figure_handle), 'JavaFrame');
    javaFrame.setFigureIcon(javax.swing.ImageIcon('icon.png'));
    %----------------------------------------------------------------------
    % �G�N��Ϥ����e�g���Ƥ��A��ֹ��ɸ��|���]�p�C
    cgrg_long_logo_image=get_cgrg_long_logo_image();
    %--
    % �]�w�y�жb
    %axes('position',[.02  .827  .4805  .2])% MATLAB2019B�A��
    axes('position',[.02  .82  .483  .2])% MATLAB2014A�A��
    %--
    % ø�sLOGO
    image(cgrg_long_logo_image)
    % �]�w�y�жb
    axis off
    axis image
    %----------------------------------------------------------------------   
    %----------------------------------------------------------------------
    program_info_str_cell={
	['Program Version: ',Program_Version_str     ]
    'Author: HsiupoYeh'
    ''
	'INI����(INI�ɮ׽Шϥ�ANSI�s�X): '
    ''
    ''
    '�������W:'
    ''
    '�����x�s���|:'
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    ''
    '���A:'
    ['    ','��l��...']
    };
    %--
    ui_listbox01_handle = uicontrol('Parent',ui_figure_handle,...
                        'Style', 'listbox',...
                        'Fontsize', 12,...
                        'FontName','Microsoft JhengHei',...
                        'String', program_info_str_cell,...
                        'max', length(program_info_str_cell),...
                        'min', 0,...
                        'Value', [],...
                        'Position', [10 10 600 540]);
    %--
    ui_pushbutton01_handle = uicontrol('Parent',ui_figure_handle,...
                        'Style', 'pushbutton',...
                        'Fontsize', 20,...
                        'FontName','Microsoft JhengHei',...
                        'String', '�ǳƤ�',...
                        'max', length(program_info_str_cell),...
                        'min', 0,...
                        'Value', [],...
                        'Enable','off',...
                        'Callback', 'HTTP_Upload_GEF_dat_and_GEF_JSON_pushbutton_callback',...
                        'Position', [350 555 250 85]);
    %--
    drawnow;    
    %----------------------------------------------------------------------
    % �إ߹B�������x�A�i�N�j�����L�b�R�O�C����r�s��
    %--
    if (exist('log/','dir')~=7)
        disp(['��Ƨ����s�b�A�s�إ�: log/'])
        mkdir('log/')
    end
    %--
    % ���w�O����x��    
    diary(['log/HTTP_Upload_GEF_dat_and_GEF_JSON_',datestr(now,'yyyymmdd'),'.log']) % �o�̫��w�s���ɦW
    %--
    % �}�l�����R�O�C����r
    diary on; 
    %----------------------------------------------------------------------
    if (exist('temp/','dir')~=7)
        disp(['��Ƨ����s�b�A�s�إ�: temp/'])
        mkdir('temp/')
    end
    %----------------------------------------------------------------------
    % Ū��INI�ɮ�
    if (exist('Input_ini\HTTP_Upload_GEF_dat_and_GEF_JSON.ini','file')~=2)
        disp('���~!�䤣��uInput_ini\HTTP_Upload_GEF_dat_and_GEF_JSON.ini�v�ɮ�!return!')
        %--
        % ��������R�O�C����r�A�ñN���e���������e�g���ɮפ��C
        diary off  
        %--
        uiwait(msgbox({'���~��]:',' ','�䤣��uInput_ini\HTTP_Upload_GEF_dat_and_GEF_JSON.ini�v�ɮ�!',' ','�������{����T�{INI�ɮפ��e���T�ʡA�A���ҵ{���C',' '},'���~','error','modal'))
        close all
        return
        %--
    else
        main_program_parameter=ini2struct_ansi('Input_ini\HTTP_Upload_GEF_dat_and_GEF_JSON.ini');        
    end
    %--
    % �T�{�s�ɸ�Ƨ��O�_�s�b
    if (exist(main_program_parameter.Local.Local_storage_path,'dir')~=7)
        disp('���~!�䤣��dat�s�ɸ�Ƨ�!return!')
        %--
        % ��������R�O�C����r�A�ñN���e���������e�g���ɮפ��C
        diary off  
        %--
        uiwait(msgbox({'���~��]:',' ','�䤣��dat�s�ɸ�Ƨ�!',' ','�������{����T�{��Ƨ���m�A�A���ҵ{���C',' '},'���~','error','modal'))
        close all
        return
        %--
    end
    %--
    % ��sGUI��r
    program_info_str_cell={
	['Program Version: ',Program_Version_str]
    'Author: HsiupoYeh'
    ''
	'INI����: '
    ['    ',main_program_parameter.Version.Version]
    ''
    '�������W:'
    ['    ',main_program_parameter.GEF_INFO.GEF_INFO_station_full_name]
    '�����x�s���|:'
    ['    ',main_program_parameter.Local.Local_storage_path]
    ''
    '�ؼгƥ�HTTP�D��(IP:Port):'
    ['    #1 = ',main_program_parameter.Target_HTTP.Target_HTTP_1_host]
    'HTTP�{���榸�ާ@�̪��ɶ�(��):'
    ['    ',main_program_parameter.Target_HTTP.Target_HTTP_max_operation_time_in_second]        
    '���ɸ���ɮ��ˬd�ɶ�(���^�ˬd�X�p�ɡA�]�t���ѡA�x�_�ɶ�):'
    ['    ',main_program_parameter.Target_HTTP.Target_HTTP_check_hour_count_from_today_UTCp8]
    '�C���ɮ��ˬd�ɶ�(���^�ˬd�X�ѡA�]�t���ѡA�x�_�ɶ�):'
    ['    ',main_program_parameter.Target_HTTP.Target_HTTP_check_day_count_from_today_UTCp8]
    ''
    '���A:'
    ['    ','���J�]�w��...���\!']
    };
    set(ui_listbox01_handle,'String', program_info_str_cell)
    %-
    % ��s���s���e
    set(ui_pushbutton01_handle,'String','���ڶ}�l')
    set(ui_pushbutton01_handle,'Enable','on')
    %--    
    % ��sfigure�W��
    set(ui_figure_handle,'Name',['HTTP_Upload_GEF_dat_and_GEF_JSON - ',main_program_parameter.GEF_INFO.GEF_INFO_station_full_name])
    %--
    drawnow;
    %--
    % ��������R�O�C����r�A�ñN���e���������e�g���ɮפ��C
    diary off   
    %======================================================================
    
    

    