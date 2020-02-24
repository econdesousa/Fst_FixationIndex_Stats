function [POP1,POP2,POP3]=filter_vcf(vcf_matrix,header_name,header1,header2,varargin)
% FILTER_VCF - split vcf into populations
%
%
% vcf_matrix:   Matrix witn genotypes
%           :   size(vcf_matrix) = NunLoci x NumIndiv x 2
%
% header_name:  cellstring with individuals names (all)
% header1:      cellstring with individuals names (Pop1)
%               or
%               file to load individuals names
% header2:      cellstring with individuals names (Pop2)
%               or
%               file to load individuals names
%
% POP1:         Matrix witn genotypes (POP1)
%     :         size(vcf_matrix) = NunLoci x NumIndivPOP1 x 2
%
% POP2:         Matrix witn genotypes (POP2)
%     :         size(vcf_matrix) = NunLoci x NumIndivPOP1 x 2
%
% USAGE:
%       [POP1,POP2]=filter_vcf(vcf_matrix,header_name,header1,header2)
%
%       [POP1,POP2]=filter_vcf(vcf_matrix,header_name,'header1.txt','header2.txt')
%
%       [POP1,POP2,POP3]=filter_vcf(vcf_matrix,header_name,header1,header2,header3)
%
%       [POP1,POP2,POP3]=filter_vcf(vcf_matrix,header_name,'header1.txt','header2.txt',header3)
%




if nargin <4
    error('Not enough input arguments')
end


if ~iscellstr(header1)    
    if exist(header1,'file')
        header1 = read_sampe_pops( header1 );
    elseif ischar(header1)
        header1={header1};
    end
end


if ~iscellstr(header2)    
    if exist(header2,'file')
        header2 = read_sampe_pops( header2 );
    elseif ischar(header2)
        header2={header2};
    end
end




POP3=cell(size(varargin));

if nargin >3
    [~,ii,~]=intersect(header_name,header1);
    POP1=vcf_matrix(:,ii,:);
    [~,ii,~]=intersect(header_name,header2);    
    POP2=vcf_matrix(:,ii,:);
    if nargin >4
        for jj=1:numel(varargin)
            header1 = varargin{jj};
            if ~iscellstr(header1)
                if exist(header1,'file')
                    header1 = read_sampe_pops( header1 );
                elseif ischar(header1)
                    header1={header1};
                end
            end
            [~,ii,~]=intersect(header_name,header1);            
            POP3{jj}=vcf_matrix(:,ii,:);
        end
    end
end

if numel(POP3)==1
    POP3=POP3{1};
end
