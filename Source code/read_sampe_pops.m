function [ out ] = read_sampe_pops( str )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

fid = fopen(str,'r');

if fid == -1
 error('couldn''t open the file')
end

out=cell(1,1);

tmp = fgetl(fid);
while tmp~=-1
    out{end+1}=tmp; %#ok<AGROW>
    tmp = fgetl(fid);
end
out(1)=[];

end

