function dbpath = getDropbox(macbook)
% dbpath = getDropbox(macbook)

% define path depending on platform
if macbook == 1; 
    dbpath =  '/Users/dbang/Dropbox';
else
    dbpath =  'C:\Users\dbang\Dropbox';
end

end