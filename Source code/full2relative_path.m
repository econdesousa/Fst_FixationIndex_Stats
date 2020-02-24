function [outarg] = full2relative_path(path,PWD)
%% FULL2RELATIVE_PATH - transforms a fullpath to a path relative to a second.
%
% One or two arguments are allowed: a string defining a path and other
% defining a reference path, if the second string is not given pwd is
% considered
%
%
% Created by Eduardo Conde-Sousa on Nov 2015
% econdesousa@gmail.com



if nargin == 1
    PWD=pwd;
elseif nargin ~= 2
    error('wrong nargin')
end

if strcmp(path(end),filesep)
    path=path(1:end-1);
end
if strcmp(PWD(end),filesep)
    PWD=PWD(1:end-1);
end


%%
lenpath=length(path);
lenPWD=length(PWD);


if strcmp(path(1:min([lenpath,lenPWD])),PWD(1:min([lenpath,lenPWD]))) %one is (maybe) contained in the other
    if strcmp(path,PWD) %path=PWD
        outarg = ['.' filesep];
    elseif lenpath<lenPWD && strcmp(PWD(lenpath+1),filesep)%path is (definitively) contained in the PWD
        ind = regexp(PWD(lenpath+2:end),filesep);
        outarg='';
        for ii= 1:length(ind)+1
            outarg=[outarg '..' filesep]; %#ok<AGROW>
        end
    elseif lenPWD<lenpath && strcmp(path(lenPWD+1),filesep)%PWD is (definitively) contained in the path
        outarg = path(lenPWD+2:end);
    else
        outarg = general_case(path,PWD);
    end
else
    outarg = general_case(path,PWD);
end


if length(outarg)>=4
    if strcmp('.\..',outarg(1:4))
        outarg = outarg(3:end);
    end
end



end

function outarg = general_case(path,PWD)
ind = intersect( regexp(path,filesep),regexp(PWD,filesep) );
for ii=1:length(ind)
    if ~strcmp(path(1:ind(ii)),PWD(1:ind(ii))),
        break
    end
end
ind=ind(ii);

path(1:ind)=[];
PWD(1:ind)=[];

ind = unique(regexp(PWD,filesep));
outarg=['.' filesep];
for ii= 1:length(ind)+1
    outarg=[outarg '..' filesep]; %#ok<AGROW>
end
outarg=[outarg path];
end