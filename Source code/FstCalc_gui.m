function fst=FstCalc_gui(varargin)
%% FSTCALC_GUI - User Interface that compute Fst statistics
% 
% opens a user interface that allows the selection of a vcf file and
% multiple text files with sub-populations info and returns the Fst statistics
%
%
% Created on June 2016 by
%
%       * Eduardo Conde-Sousa <econdesousa@gmail.com>
%
% and 
%
%       * Hugo Magalhaes    <hugocarmaga@hotmail.com>

%% new Figure

TITLE = 'Fst statistics';

addpath(genpath('.'));

POP1=[];
POP2=[];
POP3=[];
POP4=[];
POP5=[];
POP6=[];
POP7=[];
POP8=[];
POP9=[];
POP10=[];
POP11=[];
POP12=[];
POP13=[];
POP14=[];
POP15=[];
POP16=[];
POP17=[];
POP18=[];
POP19=[];

color_back = 0.5*ones(1,3);
UserGui.fig = figure('Name',TITLE,'NumberTitle','off','MenuBar','none','ToolBar','none');
UserGui.fig.Units='pixels';%'normalized';
UserGui.fig.Position=[30,60,1306,648];%[0.2,0.2,.6,.6];



path ='';
setappdata(UserGui.fig,'path',path);
method='W&C 1984';
setappdata(UserGui.fig,'method',method);
SamplePops={};
setappdata(UserGui.fig,'SamplePops',SamplePops);


%% Main Buttons
%Select File Button%
UserGui.buttonINPUT = uicontrol('Parent', UserGui.fig,'Style','pushbutton',...
    'Units','normalized',...
    'Position',[0.02 0.85 0.96 0.1],...
    'String','Select Input File',...
    'BackgroundColor',color_back,...
    'FontSize',14,...
    'Callback',@buttonINPUT_callback);

UserGui.textfile = uicontrol('Parent', UserGui.fig,'Style','text',...
    'Units','normalized',...
    'String',path,...
    'HorizontalAlignment','left',...
    'Position',[0.02 0.75 0.896 0.08]);



%Run BUTTON
UserGui.buttonRun = uicontrol('Parent', UserGui.fig,'Style','pushbutton',...
    'BackgroundColor',color_back,...
    'Units','normalized',...
    'Position',[0.02 0.05 0.96 0.15],...
    'String','Proceed...',...
    'FontSize',18,...
    'Callback',@buttonRun_callback);

%% Other Buttons
%Help BUTTON
UserGui.buttonHelp = uicontrol('Parent', UserGui.fig,'Style','pushbutton',...
    'BackgroundColor',color_back,...
    'Units','normalized',...
    'Position',[0.55 0.33 0.4 0.15],...
    'String','HELP',...
    'FontSize',14,...
    'Callback',@buttonHelp_callback);


UserGui.bg = uibuttongroup('Parent', UserGui.fig,'Visible','off',...
    'Units','normalized',...
    'Position',[0.05 0.3 .2 .4],...
    'SelectionChangedFcn',@bselection);

% Create three radio buttons in the button group.
radio(1) = uicontrol('Parent', UserGui.bg,'Style',...
    'radiobutton',...
    'String','W&C 1984',...
    'FontSize',14,...
    'Units','normalized',...
    'Position',[0.05 .8 .6 .1],...
    'HandleVisibility','off');

radio(2) = uicontrol('Parent', UserGui.bg,'Style','radiobutton',...
    'String','Nei 1973',...
    'FontSize',14,...
    'Units','normalized',...
    'Position',[0.05 .6 .6 .1],...
    'HandleVisibility','off');

radio(3) = uicontrol('Parent', UserGui.bg,'Style','radiobutton',...
    'String','Hedrick 2005',...
    'FontSize',14,...
    'Units','normalized',...
    'Position',[0.05 .4 .6 .1],...
    'HandleVisibility','off');

radio(4) = uicontrol('Parent', UserGui.bg,'Style','radiobutton',...
    'String','Jost 2008',...
    'FontSize',14,...
    'Units','normalized',...
    'Position',[0.05 .2 .6 .1],...
    'HandleVisibility','off');

% Make the uibuttongroup visible after creating child objects.
UserGui.bg.Visible = 'on';
    function bselection(hObject,eventdata)
       display(['Previous: ' eventdata.OldValue.String]);
       display(['Current: ' eventdata.NewValue.String]);
       display('------------------');
       setappdata(UserGui.fig,'method',eventdata.NewValue.String);
    end


%Sample pops BUTTON
UserGui.SamplePops = uicontrol('Parent', UserGui.fig,'Style','pushbutton',...
    'BackgroundColor',color_back,...
    'Units','normalized',...
    'Position',[0.55 0.53 .4 0.15],...
    'String','Select Populations',...
    'FontSize',14,...
    'Callback',@buttonSamplePops_callback);

%%
waitfor(UserGui.buttonRun)



    function buttonINPUT_callback(hObject,eventdata)
        path = Selectfile(false,'*.vcf','Select file');
        set(UserGui.textfile,'String',path);
        path=full2relative_path(path);
        setappdata(UserGui.fig,'path',path);     
        [~,Name,Ext]=fileparts(path);
        set(UserGui.buttonINPUT,'String',['selected file: ',Name,Ext]);
        if length([Name,Ext])>70    
            set(UserGui.buttonINPUT,'FontSize',10);
        end
    end

    
    function buttonHelp_callback(hObject, eventdata)
        web('help_code.html')
    end

    function buttonSamplePops_callback(hObject, eventdata)
           x = inputdlg('Enter number of Populations:',...
                '#Pops', 1);
            nIndv = str2num(x{:}); %#ok<ST2NM>
            while isempty(nIndv) || any(size(nIndv)>1) || floor(nIndv)~=nIndv %%%%%%%%%%%%%%%%%%% nIndv >2
                if any(size(nIndv)>1)
                    h = Error_MSG('Only one value is allowed');
                elseif isempty(nIndv)
                    h = Error_MSG('Input should be an integer number');
                elseif floor(nIndv)~=nIndv
                    h = Error_MSG('Input should be an integer number');
                end
                pause(1);
                x = inputdlg('Enter number of Populations:',...
                    '#Pops', 1);
                nIndv = str2num(x{:}); %#ok<ST2NM>
                if isvalid(h)
                    close(h);
                end
            end

           SamplePops=cell(nIndv,1);
           for ii=1:nIndv
               SamplePops{ii} = Selectfile(false,'*.*','Select file');
           end
           setappdata(UserGui.fig,'SamplePops',SamplePops);
    end




    function buttonRun_callback(hObject,eventdata)

        path = getappdata(UserGui.fig,'path');
        if numel(path)<=4 || ~strcmpi(path(end-3:end),'.vcf')
                warning('Please select a *.vcf file.')
                warndlg('Please select a *.vcf file.','!! Warning !!','modal')
        else
            method = getappdata(UserGui.fig,'method');
            fprintf('\n\n\n');
            fprintf('\t*\tInput file:\n\t\t\t%s\n\n',path)
            fprintf('\t*\tMethod:\n\t\t\t%s\n\n',method)
            
            SamplePops=getappdata(UserGui.fig,'SamplePops');

            if strcmp( method,'W&C 1984')
                display('executing W&C 1984')
                h=load_vcf('-struct',path);
                POPS_out = '';
                for ii=1:numel(SamplePops)
                    POPS_out = [POPS_out 'POP' num2str(ii) ' , ' ]; %#ok<AGROW>
                end
                POPS_out(end-1:end)=[];
                POPS_in = '';
                for ii=1:numel(SamplePops)
                    POPS_in = [POPS_in sprintf('''%s''',SamplePops{ii}) ' , ' ]; %#ok<AGROW>
                end
                POPS_in(end-1:end)=[];
                eval(['[' POPS_out '] = filter_vcf(h.SNP,h.header_name,' POPS_in ');']); %#function filter_vcf
                eval(['fst = weir_fst( ' POPS_out ');']);%#function weir_fst
                fid = fopen('WeirCockerham.txt','w');
                fprintf(fid,'CHROM\tID\tPOSITION\tTHETA\n');
                for ii = 1: numel(fst)
                    if isnan( fst(ii))
                        fprintf(fid,'%s\t%s\t%d\t%s\n',h.CHROM{ii},h.ID{ii},h.POS(ii),'NaN');
                    else
                        fprintf(fid,'%s\t%s\t%d\t%0.4f\n',h.CHROM{ii},h.ID{ii},h.POS(ii),fst(ii));
                    end
                end
                fclose(fid);
                
                
                
            elseif strcmp( method,'Nei 1973')            
                display('executing Nei 1973')
                h=load_vcf('-struct',path);
                POPS_out = '';
                for ii=1:numel(SamplePops)
                    POPS_out = [POPS_out 'POP' num2str(ii) ' , ' ]; %#ok<AGROW>
                end
                POPS_out(end-1:end)=[];
                POPS_in = '';
                for ii=1:numel(SamplePops)
                    POPS_in = [POPS_in sprintf('''%s''',SamplePops{ii}) ' , ' ]; %#ok<AGROW>
                end
                POPS_in(end-1:end)=[];
                eval(['[' POPS_out '] = filter_vcf(h.SNP,h.header_name, ' POPS_in ');']); %#function
                eval(['fst=nei(' POPS_out ');']);%#function nei
                fid = fopen('Nei.txt','w');
                fprintf(fid,'CHROM\tID\tPOSITION\tFst\n');
                for ii = 1: numel(fst)
                    if isnan( fst(ii))
                        fprintf(fid,'%s\t%s\t%d\t%s\n',h.CHROM{ii},h.ID{ii},h.POS(ii),'NaN');
                    else
                        fprintf(fid,'%s\t%s\t%d\t%0.4f\n',h.CHROM{ii},h.ID{ii},h.POS(ii),fst(ii));
                    end
                end
                fclose(fid);
                
                
            elseif strcmp( method,'Hedrick 2005')    
                display('executing Hedrick 2005')
                h=load_vcf('-struct',path);
                POPS_out = '';
                for ii=1:numel(SamplePops)
                    POPS_out = [POPS_out 'POP' num2str(ii) ' , ' ]; %#ok<AGROW>
                end
                POPS_out(end-1:end)=[];
                POPS_in = '';
                for ii=1:numel(SamplePops)
                    POPS_in = [POPS_in sprintf('''%s''', SamplePops{ii}) ' , ' ]; %#ok<AGROW>
                end
                POPS_in(end-1:end)=[];
                eval(['[' POPS_out '] = filter_vcf(h.SNP,h.header_name, ' POPS_in ');']);
                eval(['fst=hedricks( ' POPS_out ');']);%#function hedricks
                fid = fopen('Hedrick.txt','w');
                fprintf(fid,'CHROM\tID\tPOSITION\tG_st\n');
                for ii = 1: numel(fst)
                    if isnan( fst(ii))
                        fprintf(fid,'%s\t%s\t%d\t%s\n',h.CHROM{ii},h.ID{ii},h.POS(ii),'NaN');
                    else
                        fprintf(fid,'%s\t%s\t%d\t%0.4f\n',h.CHROM{ii},h.ID{ii},h.POS(ii),fst(ii));
                    end
                end
                fclose(fid);
                
                
            elseif strcmp( method,'Jost 2008')     
                display('executing jost 2008')
                h=load_vcf('-struct',path);
                POPS_out = '';
                for ii=1:numel(SamplePops)
                    POPS_out = [POPS_out 'POP' num2str(ii) ' , ' ]; %#ok<AGROW>
                end
                POPS_out(end-1:end)=[];
                POPS_in = '';
                for ii=1:numel(SamplePops)
                    POPS_in = [POPS_in sprintf('''%s''',SamplePops{ii}) ' , ' ]; %#ok<AGROW>
                end
                POPS_in(end-1:end)=[];
                eval(['[' POPS_out '] = filter_vcf(h.SNP,h.header_name, ' POPS_in ');']);
                eval(['fst = Jost( ' POPS_out ');']); %#function Jost
                fid = fopen('Jost.txt','w');
                fprintf(fid,'CHROM\tID\tPOSITION\tD\n');
                for ii = 1: numel(fst)
                    if isnan( fst(ii))
                        fprintf(fid,'%s\t%s\t%d\t%s\n',h.CHROM{ii},h.ID{ii},h.POS(ii),'NaN');
                    else
                        fprintf(fid,'%s\t%s\t%d\t%0.4f\n',h.CHROM{ii},h.ID{ii},h.POS(ii),fst(ii));
                    end
                end
                fclose(fid);
                
                
            end
            close(UserGui.fig)
        end
        
        

    end


end
