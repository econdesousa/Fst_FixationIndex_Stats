function [Theta ,F, f] = weir_fst( POP1,POP2, varargin )
% WEIR_FST - determines W&C Theta (W&C, 1984)
%   Returns Weir & Cockerham's theta value described in their article from
%   1984
%
% POP1:         Matrix with genotypes (POP1)
%     :         size(vcf_matrix) = NunLoci x NumIndivPOP1 x 2
% POP2:         Matrix with genotypes (POP2)
%     :         size(vcf_matrix) = NunLoci x NumIndivPOP1 x 2
%
%USAGE:
%   [Theta,F,f]=weir_fst(POP1,POP2)
% Created on June 2016 by
%
%       * Eduardo Conde-Sousa <econdesousa@gmail.com>
%
% and 
%
%       * Hugo Magalhaes    <hugocarmaga@hotmail.com>


Theta = NaN;
F=NaN;
f=NaN;

if size(POP1,1) ~= size(POP2,1)
    error(' ')
end


%%
NumPop = nargin;

%%
N_bar = size(POP1,2)+size(POP2,2);

if NumPop>2
    for ii=3:NumPop
        N_bar = N_bar + size(varargin{ii-2},2);
    end
end
N_bar=N_bar / NumPop;

%%
N_c = NumPop * N_bar;
N_c = N_c - (size(POP1,2).^2 )./ (NumPop * N_bar);
N_c = N_c - (size(POP2,2).^2 )./ (NumPop * N_bar);
if NumPop>2
    for ii=3:NumPop
        N_c = N_c - (size(varargin{ii-2},2).^2 )./ (NumPop * N_bar);
    end
end

N_c = N_c ./( NumPop -1 );




NAlleles = zeros(size(POP1,1),1);
AllPOPS = [POP1,POP2];
for ii=1:numel(varargin)
    AllPOPS=[AllPOPS varargin{ii}]; %#ok<AGROW>
end


for ii=1:size(POP1,1)
    NAlleles(ii) = numel(unique(AllPOPS(ii,:,:)));
end
freqs = cell(size(POP1,1),1);
Alleles =cell(size(POP1,1),1);
for ii=1:size(POP1,1)
    p_i = zeros(NumPop,NAlleles(ii));
    Alleles_tmp = unique(AllPOPS(ii,:,:));
    Alleles{ii} = Alleles_tmp;
    for jj=1:NAlleles(ii)        
         p_i(1,jj) = sum(sum(POP1(ii,:,:)==Alleles_tmp(jj),2),3) ./ (size(POP1,2)*2);
         p_i(2,jj) = sum(sum(POP2(ii,:,:)==Alleles_tmp(jj),2),3) ./ (size(POP2,2)*2);
         if NumPop>2
             for kk=3:NumPop
                 p_i(kk,jj) = sum(sum(varargin{kk-2}(ii,:,:)==Alleles_tmp(jj),2),3) ./ (size(varargin{kk-2},2)*2);
             end
         end
    end
    freqs{ii} = p_i;
end





%% n_i
n_i = zeros(1,NumPop);
n_i(1)=size(POP1,2);
n_i(2)=size(POP2,2);
if NumPop>2
    for ii=3:NumPop
        n_i(ii) = size(varargin{ii-2},2);
    end
end
n_i=n_i';

P_bar =cell(size(POP1,1),1);
S_square=cell(size(POP1,1),1);
h_i=cell(size(POP1,1),1);
H_bar=cell(size(POP1,1),1);
a=cell(size(POP1,1),1);
b=cell(size(POP1,1),1);
c=cell(size(POP1,1),1);

    
    
for locus =1:size(POP1,1)

    p_i = freqs{locus};
    %% P_bar
    P_bar{locus} = (bsxfun(@times, n_i,p_i)) ./ (NumPop * N_bar);
    P_bar{locus} = sum(P_bar{locus},1);

    %%

    S_square{locus} = (repmat( n_i,1,size(p_i,2)).* (p_i - repmat(P_bar{locus},size(p_i,1),1) ).^2);
    S_square{locus} = S_square{locus} ./ (( NumPop -1 ) * N_bar);
    S_square{locus} = sum(S_square{locus},1);


    %%
    h_i_ = zeros(NumPop,size(p_i,2));
    for allele=1:NAlleles(locus)
        h_i_(1,allele) = sum(abs((POP1(locus,:,1)==Alleles{locus}(allele))-(POP1(locus,:,2)==Alleles{locus}(allele))))./size(POP1,2);
        h_i_(2,allele) = sum(abs((POP2(locus,:,1)==Alleles{locus}(allele))-(POP2(locus,:,2)==Alleles{locus}(allele))))./size(POP2,2);
        
        if NumPop>2
            for ii=3:NumPop
                h_i_(ii,allele) = sum(abs((varargin{ii-2}(locus,:,1)==Alleles{locus}(allele))-(varargin{ii-2}(locus,:,2)==Alleles{locus}(allele))))./size(varargin{ii-2},2);
            end
        end
        
    end
    h_i{locus} = h_i_;
    %%
    H_bar{locus} = sum(bsxfun(@times, n_i,h_i{locus})./ (NumPop * N_bar));


    %%   
   
    
    a{locus} = (N_bar / N_c) .* ( S_square{locus} - 1./(N_bar -1) .* (P_bar{locus}.*(1-P_bar{locus})- ((NumPop - 1) .* S_square{locus}) ./ NumPop - (1/4).* H_bar{locus}));

    b{locus} = (N_bar)./(N_bar-1) .* ( P_bar{locus}.*(1-P_bar{locus}) - ((NumPop - 1) .* S_square{locus}) ./ NumPop - ((2*N_bar -1).*H_bar{locus})./(4*N_bar));

    c{locus} = (1/2).*H_bar{locus};
    

    Theta(locus,1) = sum(a{locus})./sum( a{locus}+b{locus}+c{locus});
    F(locus,1) = 1- (sum(c{locus})./sum(a{locus}+b{locus}+c{locus}));
    f(locus,1) = 1- (sum(c{locus})./sum(b{locus}+c{locus}));
end
%%




end

