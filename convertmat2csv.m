% 1) Put the function file mat2csv_patresult.m on your MATLAB path.
% 2) Make sure the output folder exists or create it:
outdir = 'D:\Tat_ss\IRI\TEC\TEC-calculation-MATLAB\r30s_v01\';
if ~exist(outdir, 'dir'), mkdir(outdir); end

outname = 'CM013160';
% Safely join folder path and name
outfold = append(outdir, outname,'_csv\');
% Create the folder
if ~exist(outfold, 'dir')
    mkdir(outfold);
end


% 3) Call with your .mat file and the output folder (ending with \ or /).
inmat= append(outname,'.mat')
mat2csv_patresult_rnx3(inmat, outfold, outname);