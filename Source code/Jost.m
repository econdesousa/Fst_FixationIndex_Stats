function [D_est] = Jost( POP1,POP2, varargin )
% Jost's D - determines Jost's D (2008)
%   Returns Jost's D value described in his article from 2008
%
% POP1:         Matrix witn genotypes (POP1)
%     :         size(vcf_matrix) = NunLoci x NumIndivPOP1 x 2
% POP2:         Matrix witn genotypes (POP2)
%     :         size(vcf_matrix) = NunLoci x NumIndivPOP1 x 2
%
%USAGE:
%   D_est=Jost(POP1,POP2)
% Created on June 2016 by
%
%       * Eduardo Conde-Sousa <econdesousa@gmail.com>
%
% and 
%
%       * Hugo Magalhaes    <hugocarmaga@hotmail.com>

%%
NumPop = nargin;


if size(POP1,1) ~= size(POP2,1)
    error(' ')
end

NAlleles = zeros(size(POP1,1),1);
AllPOPS = [POP1,POP2];
for ii=1:numel(varargin)
    AllPOPS=[AllPOPS varargin{ii}];
end


for ii=1:size(POP1,1)
    NAlleles(ii) = numel(unique(AllPOPS(ii,:,:)));
end
Hj=zeros(size(POP1,1),NumPop);
freqs = cell(size(POP1,1),1);
for ii=1:size(POP1,1)
    p_i = zeros(NumPop,NAlleles(ii));
    Hj_tmp = zeros(NumPop,1);
    Alleles = unique(AllPOPS(ii,:,:));
    for jj=1:NAlleles(ii)        
         p_i(1,jj) = sum(sum(POP1(ii,:,:)==Alleles(jj),2),3) ./ (size(POP1,2)*2);
         p_i(2,jj) = sum(sum(POP2(ii,:,:)==Alleles(jj),2),3) ./ (size(POP2,2)*2);
         if NumPop>2
             for kk=3:NumPop
                 p_i(kk,jj) = sum(sum(varargin{kk-2}(ii,:,:)==Alleles(jj),2),3) ./ (size(varargin{kk-2},2)*2);
             end
         end
    end
    freqs{ii} = p_i;
    for kk = 1:NumPop
        Hj_tmp(kk)=1-sum(p_i(kk,:).^2);
    end
    Hj(ii,:) = Hj_tmp';
end

%% H_S and H_T

H_S = sum(Hj,2)./size(Hj,2);

H_T = zeros(size(POP1,1),1);
for ii=1:size(POP1,1)
    H_T(ii) = 1-sum( ((1/NumPop)*sum( freqs{ii} )).^2 );
end

%% N_h

PopSize = zeros(1,nargin);
PopSize(1,1) = size(POP1,2);
PopSize(1,2) = size(POP2,2);
for ii = 1:numel(varargin)
    PopSize(1,ii+2) = size(varargin(ii),2);
end
N_h = harmmean(PopSize);

%% HS_est and HT_est

HS_est=(2*N_h/(2*N_h-1))*H_S;

HT_est=H_T+HS_est/(2*N_h*NumPop);

%% D_est

D_est=((HT_est-HS_est)./(1-HS_est)).*(NumPop/(NumPop-1));

end

