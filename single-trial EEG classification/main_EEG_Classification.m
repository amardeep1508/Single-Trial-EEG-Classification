% (c) Haider Raza, Intelligent System Research Center, University of Ulster, Northern Ireland, UK.
%     Raza-H@email.ulster.ac.uk
%     Date: 27-Jan-2014
% Cite this work on the citation given below
% @article{raza2015adaptive,
%   title={Adaptive learning with covariate shift-detection for motor imagery-based brain--computer interface},
%   author={Raza, Haider and Cecotti, Hubert and Li, Yuhua and Prasad, Girijesh},
%   journal={Soft Computing},
%   pages={1--12},
%   year={2015},
%   publisher={Springer}
% }
%  % -------------------------------------------------------------------------
%                  File Name: Single-Trial EEG classification
%                           HAIDER RAZA (18/11/2014)
%
close all
clear
clc
warning off
addpath(genpath('functions'))

%% Define bands for filtering
Subject_No='A01';
order = 4;   % Order of the filter
band=[8 12; 14 30];

do_preprocess=0;
if(do_preprocess==1)
    %==========================================================================
    %%                   Load DATASET Training Data
    disp('########   Loading Data    ##################')
    disp('Subject: A01')
    load('DataSet2a_A01T_Old.mat');
    load('A01T.mat');
    EEG_SIG_Tr=EEG_SIG;
    Labels_T=classlabel;
    Triggers_T=Triggers_A01T;
    
    load('DataSet2a_A01E_Old.mat');
    load('A01E.mat');
    EEG_SIG_Ts=EEG_SIG;
    Labels_E=classlabel;
    Triggers_E=Triggers_A01E;
    disp('#######  Extracting Features for Each band and Applying CSP ##########')
    [Features]=f_Feature_Extraction(EEG_SIG_Tr, EEG_SIG_Ts,Labels_T, Labels_E,Triggers_T, Triggers_E, band, order, Subject_No, SamplingRate_A01T);
    
    save('Features_A01.mat', 'Features')
else
    load('Features_A01.mat', 'Features')
end
Count=0;
[No_Filters,dim]=size(band);
for k=1:No_Filters
    Temp=band(k,:);
    for l=1:No_Filters
        if(find((Features{1,l}.band )==Temp))
            TEMP_TrX=Features{1,l}.Train_X;
            TEMP_Tr_Y=Features{1,l}.Train_Y;
            TEMP_TsX=Features{1,l}.Test_X;
            TEMP_Ts_Y=Features{1,l}.Test_Y;
            Count=Count+1;
            if(Count==1)
                Train_X=TEMP_TrX;
                Train_Y=TEMP_Tr_Y;
                Test_X=TEMP_TsX;
                Test_Y=TEMP_Ts_Y;
            else
                Train_X=cat(1,Train_X,TEMP_TrX);
                Test_X=cat(2,Test_X,TEMP_TsX);
            end
        else
        end
    end
end
%==========================================================================
%#################### Training #################################
% Train the Classifiers on Training Data
size(Train_X)
disp('#######  Training The SVM Classsifier ##########')
TR_MDL.svm_mdls=svmtrain(Train_X,Train_Y,'showplot',true,'kktviolationlevel',0.05);
TR_MDL.svm_mdls


%% Perform 10-Fold Cross_validation
disp('########  Applying Cross-Validation    #################')
CASE='SVM';
[acc]=Cross_Validation_Haider(Train_Y', Train_X',CASE);
CV_acc=acc.*100

%% Evaluation or Testing

[Label]=f_Adaptive_Learning_A(Test_X,TR_MDL);

%%  SVM Classification accuracy---------------------------------------------
SVM_class_error_Eval=(Test_Y-Label.SVM); %% The error from the classifier
SVM_ac=(1-(sum((SVM_class_error_Eval).^2)./length(SVM_class_error_Eval)))*100



