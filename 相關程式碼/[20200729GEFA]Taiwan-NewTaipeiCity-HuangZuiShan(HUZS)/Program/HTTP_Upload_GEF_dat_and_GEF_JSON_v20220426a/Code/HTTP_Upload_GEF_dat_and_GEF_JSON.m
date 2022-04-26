%**************************************************************************
%   Name: HTTP_Upload_GEF_dat_and_GEF_JSON.m v20201019a
%   Copyright:  
%   Author: HsiupoYeh 
%   Version: v20201019a
%   Description: 監控資料夾中是否有需要上傳或轉檔的dat檔案，若有則上傳。
%                不同MATLAB版本的圖片位置可能要手動調整。
%  運行需求外部檔案:HTTP_Upload_GEF_dat_and_GEF_JSON_pushbutton_callback.m
%                  get_cgrg_logo_image.m
%                  get_cgrg_long_logo_image.m
%                  ini2struct_ansi.m
%                  curl.exe
%                  libcurl.dll
%**************************************************************************
clear;clc;close all
Program_Version_str='v20201019a';
    %==========================================================================
    % 產生uitable表格，來展示內容
    %--------------------------------------------------------------------------
    % 建立UI用的figure並設定為不可視，尺寸設定640x660
    ui_figure_handle = figure('OuterPosition',[1,1,625,680],'Visible','off');
    %--
    % 設定其他figure參數
    %--
    % 不可改變figure大小。
    set(ui_figure_handle,'Resize','off')
    % 隱藏選單列
    set(ui_figure_handle,'MenuBar','none')
    % 隱藏工具列
    set(ui_figure_handle,'ToolBar','none')
    % 隱藏figure數字
    set(ui_figure_handle,'NumberTitle','off')
    % 設定figure名稱
    set(ui_figure_handle,'Name','HTTP_Upload_GEF_dat_and_GEF_JSON')
    %--
    set(ui_figure_handle,'DeleteFcn','disp(''使用者關閉程式!'');return;')
    % 移動到螢幕中間
    movegui(ui_figure_handle,'center')
    % 改為可視
    set(gcf,'Visible','on');
    %--
    % 故意把圖片內容寫到函數中，減少圖檔路徑的設計。
    cgrg_logo_image=get_cgrg_logo_image();
    imwrite(cgrg_logo_image,'icon.png')
    %--
    % 設定icon
    javaFrame=get(handle(ui_figure_handle), 'JavaFrame');
    javaFrame.setFigureIcon(javax.swing.ImageIcon('icon.png'));
    %----------------------------------------------------------------------
    % 故意把圖片內容寫到函數中，減少圖檔路徑的設計。
    cgrg_long_logo_image=get_cgrg_long_logo_image();
    %--
    % 設定座標軸
    %axes('position',[.02  .827  .4805  .2])% MATLAB2019B適用
    axes('position',[.02  .82  .483  .2])% MATLAB2014A適用
    %--
    % 繪製LOGO
    image(cgrg_long_logo_image)
    % 設定座標軸
    axis off
    axis image
    %----------------------------------------------------------------------   
    %----------------------------------------------------------------------
    program_info_str_cell={
	['Program Version: ',Program_Version_str     ]
    'Author: HsiupoYeh'
    ''
	'INI版本(INI檔案請使用ANSI編碼): '
    ''
    ''
    '測站全名:'
    ''
    '本機儲存路徑:'
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
    '狀態:'
    ['    ','初始化...']
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
                        'String', '準備中',...
                        'max', length(program_info_str_cell),...
                        'min', 0,...
                        'Value', [],...
                        'Enable','off',...
                        'Callback', 'HTTP_Upload_GEF_dat_and_GEF_JSON_pushbutton_callback',...
                        'Position', [350 555 250 85]);
    %--
    drawnow;    
    %----------------------------------------------------------------------
    % 建立運行紀錄日誌，可將大部分印在命令列的文字存檔
    %--
    if (exist('log/','dir')~=7)
        disp(['資料夾不存在，新建立: log/'])
        mkdir('log/')
    end
    %--
    % 指定記錄日誌檔    
    diary(['log/HTTP_Upload_GEF_dat_and_GEF_JSON_',datestr(now,'yyyymmdd'),'.log']) % 這裡指定存檔檔名
    %--
    % 開始紀錄命令列的文字
    diary on; 
    %----------------------------------------------------------------------
    if (exist('temp/','dir')~=7)
        disp(['資料夾不存在，新建立: temp/'])
        mkdir('temp/')
    end
    %----------------------------------------------------------------------
    % 讀取INI檔案
    if (exist('Input_ini\HTTP_Upload_GEF_dat_and_GEF_JSON.ini','file')~=2)
        disp('錯誤!找不到「Input_ini\HTTP_Upload_GEF_dat_and_GEF_JSON.ini」檔案!return!')
        %--
        % 停止紀錄命令列的文字，並將之前紀錄的內容寫到檔案中。
        diary off  
        %--
        uiwait(msgbox({'錯誤原因:',' ','找不到「Input_ini\HTTP_Upload_GEF_dat_and_GEF_JSON.ini」檔案!',' ','請關閉程式後確認INI檔案內容正確性，再重啟程式。',' '},'錯誤','error','modal'))
        close all
        return
        %--
    else
        main_program_parameter=ini2struct_ansi('Input_ini\HTTP_Upload_GEF_dat_and_GEF_JSON.ini');        
    end
    %--
    % 確認存檔資料夾是否存在
    if (exist(main_program_parameter.Local.Local_storage_path,'dir')~=7)
        disp('錯誤!找不到dat存檔資料夾!return!')
        %--
        % 停止紀錄命令列的文字，並將之前紀錄的內容寫到檔案中。
        diary off  
        %--
        uiwait(msgbox({'錯誤原因:',' ','找不到dat存檔資料夾!',' ','請關閉程式後確認資料夾位置，再重啟程式。',' '},'錯誤','error','modal'))
        close all
        return
        %--
    end
    %--
    % 更新GUI文字
    program_info_str_cell={
	['Program Version: ',Program_Version_str]
    'Author: HsiupoYeh'
    ''
	'INI版本: '
    ['    ',main_program_parameter.Version.Version]
    ''
    '測站全名:'
    ['    ',main_program_parameter.GEF_INFO.GEF_INFO_station_full_name]
    '本機儲存路徑:'
    ['    ',main_program_parameter.Local.Local_storage_path]
    ''
    '目標備份HTTP主機(IP:Port):'
    ['    #1 = ',main_program_parameter.Target_HTTP.Target_HTTP_1_host]
    'HTTP程式單次操作最長時間(秒):'
    ['    ',main_program_parameter.Target_HTTP.Target_HTTP_max_operation_time_in_second]        
    '單檔資料檔案檢查時間(往回檢查幾小時，包含今天，台北時間):'
    ['    ',main_program_parameter.Target_HTTP.Target_HTTP_check_hour_count_from_today_UTCp8]
    '每日檔案檢查時間(往回檢查幾天，包含今天，台北時間):'
    ['    ',main_program_parameter.Target_HTTP.Target_HTTP_check_day_count_from_today_UTCp8]
    ''
    '狀態:'
    ['    ','載入設定檔...成功!']
    };
    set(ui_listbox01_handle,'String', program_info_str_cell)
    %-
    % 更新按鈕內容
    set(ui_pushbutton01_handle,'String','按我開始')
    set(ui_pushbutton01_handle,'Enable','on')
    %--    
    % 更新figure名稱
    set(ui_figure_handle,'Name',['HTTP_Upload_GEF_dat_and_GEF_JSON - ',main_program_parameter.GEF_INFO.GEF_INFO_station_full_name])
    %--
    drawnow;
    %--
    % 停止紀錄命令列的文字，並將之前紀錄的內容寫到檔案中。
    diary off   
    %======================================================================
    
    

    