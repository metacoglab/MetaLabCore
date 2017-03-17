function out = check_motion(dir_base, name_subj, n_sess, rotation_cutoff, affine_cutoff);
% Check for motion artefacts
%
% SF 2015

cwd = pwd;
fs = filesep;
plots = 0;

addpath('~/Dropbox/Utils/spm12');

%% Change according to your directory strucutre and scan parameters
dir_epi     = 'Functional';
sess_prfx   = 'sess';
npanel = ceil(sqrt(length(name_subj)));

if ~exist('rotation_cutoff','var') || isempty(rotation_cutoff)
    rotation_cutoff = 0.1;
end
if ~exist('affine_cutoff','var') || isempty(affine_cutoff)
    affine_cutoff = 1.5;
end

for n = 1:length(name_subj)
    
    all_affine = [];
    all_rotation = [];
    all_deriv_affine = [];
    all_deriv_rotation = [];
    for i = 1:n_sess
        
        epiDir = [dir_base fs name_subj{n} fs dir_epi fs sess_prfx num2str(i)];
        f   = spm_select('List', epiDir, '^rp_af.*\.txt$');     % Select smoothed normalised images
        motion_file = [repmat([epiDir fs],size(f,1),1) f];
        motion = textread(motion_file);
        
        affine = motion(:,1:3);
        rotation = motion(:,4:6); 
        deriv_affine = diff(affine);
        deriv_rotation = diff(rotation);
        
        all_affine = [all_affine; motion(:,1:3)];
        all_rotation = [all_rotation; motion(:,4:6)];
        all_deriv_affine = [all_deriv_affine; diff(affine)];
        all_deriv_rotation = [all_deriv_rotation; diff(rotation)];
        
        for j = 1:length(affine)
            if j == 1
                bad_scans{i}(j) = 0;
            else
                bad_scans{i}(j) = any(abs(deriv_affine(j-1,:)) > affine_cutoff);
            end
        end
    end
    
    out.bad_affine(n) = any(abs(all_deriv_affine(:)) > affine_cutoff);
    out.bad_rotation(n) = any(abs(all_deriv_rotation(:)) > rotation_cutoff);
    
    % Write .mat file with bad_scans into subject directory
    cd([dir_base fs name_subj{n} fs dir_epi])
    save('bad_scans.mat', 'bad_scans');
    cd(cwd)
    
    if out.bad_affine(n) == 1
        disp(['Translation greater than ' num2str(affine_cutoff) 'mm for subject ' name_subj{n}]);
    elseif out.bad_rotation(n) == 1
        disp(['Rotation greater than ' num2str(rotation_cutoff) ' degrees for subject ' name_subj{n}]);
    else
        disp(['Subject ' name_subj{n} ' motion OK']);
    end
    
    if plots
        figure(1);
        subplot(npanel, npanel, n);
        plot(all_affine);
        ylabel('Translation (mm)');
        set(gca, 'YLim', [-4 4]);
        figure(2);
        subplot(npanel, npanel, n);
        plot(all_rotation);
        ylabel('Rotation (deg)');
        set(gca, 'YLim', [-0.2 0.2]);
        figure(3);
        subplot(npanel, npanel, n);
        plot(deriv_affine);
        ylabel('Relative displacement (mm)');
        set(gca, 'YLim', [-3 3]);
        figure(4);
        subplot(npanel, npanel, n);
        plot(deriv_rotation);
        ylabel('Relative rotation (deg)');
        set(gca, 'YLim', [-0.1 0.1]);
    end
    
end