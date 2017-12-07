%% compile for hank2patch.cu & patch2hank.cu
% before compilation, edit nvccbat.bat

nvcc('hank2patch_single.cu -arch sm_35')
nvcc('patch2hank_single.cu -arch sm_35')