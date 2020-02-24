function [outarg] = Selectfile( varargin )
%% SELECTFILE - Select file by extension
% Three arguments are allowed: a logical value "multi" and two strings,
% "str_1" and "str_2".
%
% str_1 should be a str startind by a "*.":    
%                                           DEFAULT = "*.*" 
%
% and defines the extension of the files. Alternativelly it could be a
% cellstr. For more information see help menu of UIGETFILE
%
% multi should be a boolean indicating if it is allowed to select multiple
% files at once:                            
%                                           DEFAULT = true
%
% str_2 is the menu title (should be the last argument):
%                                           DEFAULT = "Select file"
%
% "str_1" and "str_2" should be presented by the defined order. "multi"
% could be either the 1st, the 2nd or the 3rd argument.
%
%
% Created by Eduardo Conde-Sousa on Nov 2015
% econdesousa@gmail.com

multi = true;
str_1 = '*.*';
str_2 = 'Select file';

if nargin == 1
    if isnumeric(varargin{1}) || islogical(varargin{1})
        multi = varargin{1};
    else
        str_1 = varargin{1};
    end
elseif nargin == 2
    if isnumeric(varargin{1}) || islogical(varargin{1})
        multi = boolean(varargin{1});
        str_1 = varargin{2};
    elseif isnumeric(varargin{2}) || islogical(varargin{2})
        str_1 = varargin{1};        
        multi = logical(varargin{2});
    else
        str_1 = varargin{1};  
        str_2 = varargin{2};
    end
elseif nargin == 3
        if isnumeric(varargin{1}) || islogical(varargin{1})
        multi = logical(varargin{1});
        str_1 = varargin{2};
        str_2 = varargin{3};
    elseif isnumeric(varargin{2}) || islogical(varargin{2})
        multi = logical(varargin{2});
        str_1 = varargin{1};   
        str_2 = varargin{3};
    elseif isnumeric(varargin{3}) || islogical(varargin{3})
        multi = logical(varargin{3});
        str_1 = varargin{1};   
        str_2 = varargin{2};
    else
        error('at least one arg should be a logical');
        end
elseif nargin > 3
    error('nargin <4')    
end

if ischar(str_1)
    if ~(strcmp(str_1(1),'.') || strcmp(str_1(1:2),'*.') )
        error('extention should be a char started by "*."')
    end
    if strcmp(str_1(1),'.')
        str_1 = ['*' str_1];
    end
elseif ~iscellstr(str_1)
    error('extention should be a char started by .')
end

if ~ischar(str_2)
    error('Menu Title Should be of class CHAR')
end

if multi
    M='on';
else
    M='off';
end


[SR_,path_] = uigetfile(str_1,'MultiSelect',M,str_2);

outarg = fullfile(path_,SR_);
end

