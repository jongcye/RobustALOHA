function nvcc(varargin)
% This function NVCC is a wraper for the NVIDIA Cuda compiler NVCC.exe
% in combination with a Visual Studio compiler. After this Cuda
% files can be compiled into kernels
% 
% If you call the code the first time, or with "nvcc -config":
% 1) It will try to locate the "The NVIDIA GPU Computing Toolkit", which 
% can be downloaded  from www.nvidia.com/object/cuda_get.html 
% Typical Location :
%   C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v3.2\bin
% 2) It will try to locate the visual studio compiler
% Typical Location :
%   C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\bin\
% 3) It creates a file nvccbat.bat with the compiler information.
%
% After this configuration procedure, you can compile files with:
%
%
%  nvcc(filename);
%
%  or 
% 
%  nvcc(options,filename)
%
%  filename : A string with the filename, for example 'example.cu'
%  options : NVCC Compiler options for example, 
%               nvcc(option1, option2, option3,filename)
%       
%  For help on NVCC config options type, "nvcc --help"
%  
%
%  Note!
%  If the NVCC fails to locate the compiler you can try to 
%  write your own "nvccbat.bat" file in a text-editor, for example:
%    echo off
%    set PATH=C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\bin\;%PATH%
%    set PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v3.2\bin;%PATH%
%    call vcvars32.bat
%    nvcc %1 %2 %3 %4 %5 %6 %7 %8 %9
%
%
%
%  1 Example, Configuration
%    % Locate Cuda and VS compiler
%    nvcc -config
%    
%    % Show the NVCC compiler options
%    nvcc --help
%
%    % Test some input options
%    nvcc --dryrun -ptx example.cu
%
%  2 Example,
%
%    % Locate Cuda and VS compiler
%    nvcc -config
%    % Compile the code
%    nvcc('example.cu');
%    % It the same as :
%    % nvcc -ptx example.cu
%
%    % Make the kernel
%    Kernel = parallel.gpu.CUDAKernel('example.ptx', 'example.cu');
%
%    % We want to execute this kernel 100 times
%    Kernel.ThreadBlockSize=100;
%
%    % We make an array with 100 random files
%    Data=rand(100, 1, 'single');
%    DataCuda= gpuArray(Data);
%     
%    % We will add the value 1
%    OneCuda = parallel.gpu.GPUArray.ones(1,1);
%
%    % Execute the kernel
%    DataOneCuda = feval(Kernel, DataCuda, OneCuda);
%
%    % Get the data back
%    DataOne=gather(DataOneCuda);
%   
%    % Show the result
%    figure, hold on;
%    plot(Data,'b');
%    plot(DataOne,'r');
%
% Function is written by D.Kroon University of Twente (December 2010)

if(nargin<1)
    error('nvcc:inputs','Need at least one input');
end

% Copy configuration file to current folder
functionname='nvcc.m';
functiondir=which(functionname);
functiondir=functiondir(1:end-length(functionname));
afilename=[cd '\nvccbat.bat'];
cfilename=[functiondir '\nvccbat.bat'];
if(~exist(afilename,'file'))
    if(exist(cfilename,'file'))
        fid = fopen(cfilename, 'r'); fiw = fopen('nvccbat.bat', 'w');
        fwrite(fiw,fread(fid, inf, 'uint8=>uint8'));
        fclose(fiw);  fclose(fid); 
    else
        % If configuration file doesn't exist, go to config mode
        varargin{1}='-config';
    end
end

if(strcmp(varargin{1},'-config'))
% Configuration Mode 

    % Locate the Cuda Toolkit 
    filenametoolkit=toolkit_selection;
    disp('.'); disp(['Toolkit Path: ' filenametoolkit]);
    
    % Locate the microsoft compiler
    [filenamecompiler,filenamecompilerbat]=compiler_selection();
    disp('.'); disp(['VS Compiler: ' filenamecompiler]);

    % Create a bat file which will excecute the nvcc compiler
    createbatfile(filenamecompiler,filenametoolkit, filenamecompilerbat,cfilename);
else
% Compile a .cu file using the nvcc.exe compiler

    % If no input options compile as .ptx kernel file
    if(nargin<2),
        str=['-ptx ' varargin{1}];
    else
        % Add all input options
        str=''; for i=1:nargin, str=[str varargin{i} ' ']; end
        if(nargin>9)
            warning('nvcc:inputs','Only 8 input options allowed');
        end
    end
    
    % Excecute the bat file to compile a .cu file
    [status,result] = system(['nvccbat ' str]);
    disp(result);
end


function createbatfile(filenamecompiler,filenametoolkit, filenamecompilerbat,cfilename)
fid = fopen(cfilename,'w');
fprintf(fid,'echo off\r\n');
fprintf(fid,'%s\r\n',['set PATH=' filenamecompiler ';%PATH%']);
fprintf(fid,'%s\r\n',['set PATH=' filenametoolkit ';%PATH%']);
fprintf(fid,['call ' filenamecompilerbat '\r\n']);
fprintf(fid,'nvcc %%1 %%2 %%3 %%4 %%5 %%6 %%7 %%8 %%9 \r\n');
fclose(fid);
    
% This function will try to locate the installed NVIDIA toolkits
function filenametoolkit=toolkit_selection()
str=getenv('ProgramFiles');
str=[str '\NVIDIA GPU Computing Toolkit\CUDA'];
if(~isdir(str))
    str=getenv('ProgramW6432');
    str=[str '\NVIDIA GPU Computing Toolkit\CUDA'];
    if(~isdir(str))
        str=getenv('ProgramFiles(x86)');
        str=[str '\NVIDIA GPU Computing Toolkit\CUDA'];
    else
        error('nvcc:notfound','The NVIDIA GPU Computing Toolkit is not found, please make sure you have downloaded and installed the toolkit');
    end
end
files=dir([str '\*']); 
filenametoolkitlist=cell(1,10);
n=0;
for i=1:length(files)
    if((files(i).name(1)~='.')&&files(i).isdir)
        filenametoolkit=[str '\' files(i).name '\bin'];
        if(exist(filenametoolkit,'dir')), 
            n=n+1;
            filenametoolkitlist{n}=filenametoolkit;
        end
    end
end
if(n==0)
    error('nvcc:notfound','The NVIDIA GPU Computing Toolkit is not found, please make sure you have downloaded and installed the toolkit');
end

disp('Cuda Toolkits Found : ')
disp('------------------------------------------------------------------')
for i=1:n
    disp(['[' num2str(i) ']  ' filenametoolkitlist{i}])
end
disp('------------------------------------------------------------------')
p=input('Select the Cuda Toolkit you want to use : ');
filenametoolkit=filenametoolkitlist{p};

% This function will try to locate all installed Microsoft Visual Compilers
function [filenamecompiler, filenamecompilerbat]=compiler_selection()
compilerfilenames=cell(1,10);
compilerfilenamesbat=cell(1,10);
n=0;
for j=1:3
    switch(j)
        case 1
            str=getenv('ProgramFiles');
        case 2
            str=getenv('ProgramW6432');
        case 3
            str=getenv('ProgramFiles(x86)');
    end
    if(~isempty(str))
        a=dir([str '\Microsoft Visual*']);
        for i=1:length(a)
            filename=[str '\' a(i).name '\VC\bin\amd64\'];
            filenamebat=[filename 'vcvarsamd64.bat'];
            if(exist(filenamebat,'file'))
                n=n+1;
                compilerfilenames{n}=filename;
                compilerfilenamesbat{n}='vcvarsamd64.bat';
            end
            filename=[str '\' a(i).name '\VC\bin\'];
            filenamebat=[filename 'vcvars32.bat'];
            if(exist(filenamebat,'file'))
                n=n+1;
                compilerfilenames{n}=filename;
                compilerfilenamesbat{n}='vcvars32.bat';
            end
        end
    end
end
if(n==0)
    error('nvcc:notfound','No visual studio compilers found, please make sure the compilers are installed');
end

disp('Visual studio compilers Found : ')
disp('------------------------------------------------------------------')
for i=1:n
    disp(['[' num2str(i) ']  ' compilerfilenames{i}])
end
disp('------------------------------------------------------------------')
p=input('Select the visual studio compiler you want to use : ');
filenamecompiler=compilerfilenames{p};
filenamecompilerbat=compilerfilenamesbat{p};









