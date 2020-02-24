function [CHROM, POS, ID, REF_ALT, QUAL, FILTER, INFO, FORMAT, SNP, header, header_name, NBYTES, FullFileBytes] = load_vcf(varargin)

%%LOAD_LARGE_VCF - load vcf file
% function calling:
%   opt1:
%        [CHROM, POS, ID, REF_ALT, QUAL, FILTER, INFO, FORMAT, SNP, header,NBYTES,FullFileBytes] = load_large_vcf(file,SIZE)
%
%   opt2:
%       [CHROM, POS, ID, REF_ALT, QUAL, FILTER, INFO, FORMAT, SNP, header,NBYTES,FullFileBytes] = load_large_vcf(file)
%
%   opt3:
%       structure_name = load_large_vcf(file,SIZE,'-struct')
%
%   opt4:
%       structure_name = load_large_vcf('-struct')
% 
%
% if '-struct' is called, only one output is required and that output would
% be a structure with all the other fields.
%
% file should be a filename of a *.vcf
%
% SIZE is not necessary. It will be set automatically.
%
%
% Created by Eduardo Conde-Sousa on Dec 2015
% econdesousa@gmail.com

% modified on May 2016 by Eduardo Conde-Sousato split SNP into a 3D matrix and to incorporate
% header_name field



%% Imput args
v=varargin;
st_flag = 0;
if find(strcmp(v,'-struct'))
    if nargout > 1
        error('with ''-struct'' flag only one argout is allowed')
    end
    v(find(strcmp(varargin,'-struct')))=[];
    st_flag = 1;
end

% home
% tic
if numel(v) < 2;
    SIZE = 1e9;
else
    SIZE=v{2};
end
% prevent unnecessarilly large number of loops.
if SIZE < 1e9
    SIZE = 1e9;
    warning('nbytes/read changed to 1e9');   
end


if numel(v) < 1;
    [file,path]=uigetfile('*.vcf','MultiSelect','off');
    file=fullfile(path,file);
else
    file=v{1};
end




%% Main Code
file_info=dir(file);
FullFileBytes = file_info.bytes;
%   - EOL UNIX		= FL
%   - EOL WINDOWS	= CR+LF
cr=sprintf('\r');	% 013 =  CR: carriage return
lf=sprintf('\n');	% 010 =  LF: line feed
TAB=sprintf('\t');


fid = fopen(file,'r');



if FullFileBytes>2*SIZE;
    
    
    %pointer to the byte that we last read
    NBYTES = 0;
    
    
    %read first SIZE characters
    hs1=fread(fid,SIZE,'*char').';
    %line ends for first "word"
    eol1=[0,strfind(hs1,lf),numel(hs1)+1];
    
    %read next SIZE characters
    hs2=fread(fid,SIZE,'*char').';
    
    %remove comments from the begining of file
    ii=1;
    str=deblank(hs1(eol1(ii)+1:eol1(ii+1)-1));
    header = [];
    while strcmp(str(1),'#')
        header = [ header str lf]; %#ok<AGROW>
        ii=ii+1;
        str=deblank(hs1(eol1(ii)+1:eol1(ii+1)-1));
    end
    
    NCols=sum(diff(isspace(str))==1)+1;%length(strfind( str, TAB))+1;

    %refresh hs1 (remove header lines)
    hs1=hs1(eol1(ii)+1:end);
    

    %line ends for 2nd "word"
    eol2=[0,strfind(hs2,lf)];

    %cat both words
    hs = [hs1, hs2(1:eol2(end)-1)];
    
    CHROM = [];
    POS = [];
    ID = [];
    REF_ALT=[];
    QUAL = [];
    FILTER = [];
    INFO = [];
    FORMAT = [];
    SNP = [];
    

    nbytes=numel(hs);   
    
    NBYTES = NBYTES + nbytes;
    
    while nbytes > 0
        
        [CHROM_, POS_, ID_, REF_ALT_, QUAL_, FILTER_, INFO_, FORMAT_, SNP_] = innerfunc(hs,NCols);
        
        CHROM = [CHROM ; CHROM_ ]; %#ok<AGROW>
        POS = [POS ; POS_]; %#ok<AGROW>
        ID = [ID ; ID_]; %#ok<AGROW>
        REF_ALT =[REF_ALT; REF_ALT_]; %#ok<AGROW>
        QUAL = [QUAL ; QUAL_]; %#ok<AGROW>
        FILTER = [FILTER ; FILTER_]; %#ok<AGROW>
        INFO = [INFO ; INFO_]; %#ok<AGROW>
        FORMAT = [FORMAT ; FORMAT_]; %#ok<AGROW>
        SNP = [SNP ; SNP_]; %#ok<AGROW>
        
        hs1 = hs2(eol2(end)+1:end);
        hs2=fread(fid,SIZE,'*char').'; 
        eol2=[0,strfind(hs2,lf)];
        
        hs = [hs1, hs2(1:eol2(end)-1)];
        
        nbytes=numel(hs);   
        NBYTES = NBYTES + nbytes;
        
    end
        
else
    hs=fread(fid,inf,'*char').';
    
    
    % end of line
    eol=[0,strfind(hs,lf),numel(hs)+1];
    
    
    ii=1;str=deblank(hs(eol(ii)+1:eol(ii+1)-1));
    header = [];
    while strcmp(str(1),'#')
        header = [ header str lf]; %#ok<AGROW>
        ii=ii+1;
        str=deblank(hs(eol(ii)+1:eol(ii+1)-1));
    end
    hs=hs(eol(ii)+1:end);
    NBYTES = numel(hs);
    NCols=sum(diff(isspace(str))==1)+1;%length(strfind( str, TAB))+1;

    [CHROM, POS, ID, REF_ALT, QUAL, FILTER, INFO, FORMAT, SNP] = innerfunc(hs,NCols);
    
end


fclose(fid);
    lf=sprintf('\n');
    eol=[0,strfind(deblank(header),lf),numel(deblank(header))+1];
    header_name = header(eol(end-1)+1:eol(end));
    header_name=textscan(header_name,'%s');
    header_name=header_name{1};
    header_name(1:9)=[];

if st_flag
    h.CHROM=CHROM;
    h.POS=POS;
    h.ID=ID;
    h.REF_ALT=REF_ALT;
    h.QUAL=QUAL;
    h.FILTER=FILTER;
    h.INFO=INFO;
    h.FORMAT=FORMAT;
    h.SNP=SNP;
    h.header=header;
    h.header_name=header_name;
    h.NBYTES=NBYTES;
    h.FullFileBytes=FullFileBytes;
    CHROM = h;
end

end



function [CHROM, POS, ID, REF_ALT, QUAL, FILTER, INFO, FORMAT, SNP] = innerfunc(hs,NCols)

%   - EOL UNIX		= FL
%   - EOL WINDOWS	= CR+LF
cr=sprintf('\r');	% 013 =  CR: carriage return
lf=sprintf('\n');	% 010 =  LF: line feed

if	ispc
    hs=strrep(hs,[cr,lf],lf);
end
hs=strrep(hs,char(0),'^');

ind_format = 9;

minorFormatSpec = '%u8%*[/|]%u8:%*s';
formatSpec=[repmat('%s',1,ind_format) repmat(minorFormatSpec,1,NCols-ind_format) '%*[^\n]'];
formatSpec(4) = 'f';%formatSpec(12) = 'f';


%%
% tic
LOADED_FILE=textscan(hs,formatSpec);
% toc
%%
% tic
%CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	
CHROM = LOADED_FILE{:,1};
POS = cell2mat(LOADED_FILE(:,2));
ID = LOADED_FILE{:,3};
REF_ALT=[LOADED_FILE{:,4} LOADED_FILE{:,5}];
QUAL = LOADED_FILE(:,6);
FILTER = LOADED_FILE{:,7};
INFO = LOADED_FILE{:,8};
FORMAT = LOADED_FILE{:,9};
SNP1=cell2mat(LOADED_FILE(:,10:end));

SNP=zeros([size(SNP1) 2]./[1 2 1]);
SNP(:,:,1)=SNP1(:,1:2:end);
SNP(:,:,2)=SNP1(:,2:2:end);


% toc
end

