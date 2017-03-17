% This script defines the subject details for 'fil_mri_organise_batch'

%% SUBJECT DETAILS
% subject 1
subj{1}.scanid     = 'MT04498_FIL.S';
subj{1}.localiser  = 1;
subj{1}.structural = 2;
subj{1}.functional = [4 6 7 8 9];
subj{1}.motion     = 10; 
subj{1}.fieldmaps  = [11 12];
subj{1}.delete     = [3 5 11 12];
% subject 2
subj{2}.scanid     = 'MT04524_FIL.S';
subj{2}.localiser  = 1;
subj{2}.structural = 2;
subj{2}.functional = [3 4 5 6 7];
subj{2}.motion     = 8; 
subj{2}.fieldmaps  = [9 10];
subj{2}.delete     = [];
% subject 3
subj{3}.scanid     = 'MT04525_FIL.S';
subj{3}.localiser  = 1;
subj{3}.structural = 2;
subj{3}.functional = [3 4 5 6 7];
subj{3}.motion     = 8; 
subj{3}.fieldmaps  = [9 10];
subj{3}.delete     = [];
% subject 4
subj{4}.scanid     = 'MT04527_FIL.S';
subj{4}.localiser  = 1;
subj{4}.structural = 2;
subj{4}.functional = [3 4 5 6 7];
subj{4}.motion     = 8; 
subj{4}.fieldmaps  = [9 10];
subj{4}.delete     = [];
% subject 5
subj{5}.scanid     = 'MT04535_FIL.S';
subj{5}.localiser  = 1;
subj{5}.structural = 2;
subj{5}.functional = [3 4 5 6 7];
subj{5}.motion     = 8; 
subj{5}.fieldmaps  = [9 10];
subj{5}.delete     = [];
% subject 6
subj{6}.scanid     = 'MT04530_FIL.S';
subj{6}.localiser  = 1;
subj{6}.structural = 2;
subj{6}.functional = [3 4 5 6 7];
subj{6}.motion     = 8; 
subj{6}.fieldmaps  = [9 10];
subj{6}.delete     = [];
% subject 7
subj{7}.scanid     = 'MT04537_FIL.S';
subj{7}.localiser  = 1;
subj{7}.structural = 2;
subj{7}.functional = [3 4 5 6 7];
subj{7}.motion     = 8; 
subj{7}.fieldmaps  = [9 10];
subj{7}.delete     = [];
% subject 8
subj{8}.scanid     = 'MT04534_FIL.S';
subj{8}.localiser  = 1;
subj{8}.structural = 2;
subj{8}.functional = [3 4 5 6 7];
subj{8}.motion     = 8; 
subj{8}.fieldmaps  = [9 10];
subj{8}.delete     = [];
% subject 9
subj{9}.scanid     = 'MT04576_FIL.S';
subj{9}.localiser  = 1;
subj{9}.structural = 2;
subj{9}.functional = [3 4 5 6 7];
subj{9}.motion     = 8; 
subj{9}.fieldmaps  = [9 10];
subj{9}.delete     = [];
% subject 10
subj{10}.scanid     = 'MT04573_FIL.S';
subj{10}.localiser  = 1;
subj{10}.structural = 2;
subj{10}.functional = [3 4 5 6 7];
subj{10}.motion     = 8; 
subj{10}.fieldmaps  = [9 10];
subj{10}.delete     = [];
% subject 11
subj{11}.scanid     = 'MT04578_FIL.S';
subj{11}.localiser  = 1;
subj{11}.structural = 2;
subj{11}.functional = [3 4 5 6 7];
subj{11}.motion     = 8; 
subj{11}.fieldmaps  = [9 10];
subj{11}.delete     = [];
% subject 12
subj{12}.scanid     = 'MT04580_FIL.S';
subj{12}.localiser  = 1;
subj{12}.structural = 2;
subj{12}.functional = [3 4 5 6 7];
subj{12}.motion     = 8; 
subj{12}.fieldmaps  = [9 10];
subj{12}.delete     = [];
% subject 13
subj{13}.scanid     = 'MT04582_FIL.S';
subj{13}.localiser  = 1;
subj{13}.structural = 2;
subj{13}.functional = [3 4 5 6 7];
subj{13}.motion     = 8; 
subj{13}.fieldmaps  = [9 10];
subj{13}.delete     = [];
% subject 14
subj{14}.scanid     = 'MT04596_FIL.S';
subj{14}.localiser  = 1;
subj{14}.structural = 2;
subj{14}.functional = [3 4 5 6 7];
subj{14}.motion     = 8; 
subj{14}.fieldmaps  = [9 10];
subj{14}.delete     = [];


%% Save details
save('subject_details.mat','subj');
save('../analysis/subject_details.mat','subj');