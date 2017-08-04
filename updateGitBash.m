function updateGitBash(fetchAndCheckOnly)
% INPUT:
%     fetchAndCheckOnly: if set to true, gitBash is not updated (default: false)
%

    global CBTDIR;
    global gitBashVersion;
    
    if nargin < 1
        fetchAndCheckOnly = false;
    end
    
    % define the name of the temporary folder
    tmpFolder = '.tmp';
    
    [installedVersion, installedVersionNum] = determineGitBashVersion();

    % define the path to portable gitBash
    pathPortableGit = [CBTDIR filesep tmpFolder filesep 'PortableGit-' installedVersion];

    % check if mingw64 is already in the path
    if ~isempty(installedVersion) && exist(pathPortableGit, 'dir') == 7
        fprintf([' > gitBash is installed (version: ', installedVersion, ').\n']);

        % if a version already exists, get the latest
        [status, response] = system('curl https://api.github.com/repos/git-for-windows/git/releases/latest');

        latestVersion = [];

        % find the index of occurrence
        if status == 0 && ~isempty(response)
            index1 = strfind(response, 'git/releases/tag/v');
            index2 = strfind(response, '.windows.1');
            catchLength = length('git/releases/tag/v');
            index1 = index1 + catchLength;

            if  ~isempty(index2) && ~isempty(index1)
                if index2(1) > index1(1)
                    latestVersion = response(index1(1):index2(1) - 1);
                end
            end
        end

        % if the latest version cannot be retrieved, set the latest version to the base version
        if isempty(latestVersion)
            latestVersion = gitBashVersion;
        end

        % convert the string to a number
        latestVersionNum = str2num(strrep(latestVersion, '.', ''));

        % test here if the latest version is up-to-date
        if latestVersionNum > installedVersionNum
            fprintf([' > gitBash is not up-to-date (version: ', installedVersion, '). Updating to version ', latestVersion, '.\n']);

            % retrieve and install the portable git bash and associated tools
            if ~fetchAndCheckOnly
                portableGitSetup(latestVersion, 1);
            end
        else
            fprintf([' > gitBash is up-to-date (version: ', installedVersion, ').\n']);
        end
    else % gitBash is not installed or the path is not properly set
        fprintf(' > gitBash is not installed.\n');
        if ~fetchAndCheckOnly
            installGitBash();
        end
    end
end
