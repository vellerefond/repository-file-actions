# repository-tabs-filter
#### A package to filter the open files using information from the repository in use.

###### The package options are available through the tab bar context menu and the explanation per option is as follows:

_**Close Repo/User Unmodified files**_ closes any open file that is not new of modified in the repository and any other files that would not show up by doing a _git status_ in the repository's working directory and the user has not modified.

_**Keep Only Repo New/User Modified Files**_ keeps open only the files marked as new in the repository, as well as any other file that would not show up by doing a _git status_ in the repository's working directory and the user has modified.

_**Open Repo New Files**_ opens any file not already opened that would show up as new by doing a _git status_ in the repository's working directory.

_**Open Repo Modified Files**_ opens any file not already opened that would show up as modified by doing a _git status_ in the repository's working directory.
