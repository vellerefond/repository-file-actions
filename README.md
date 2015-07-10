# repository-tabs-filter
#### A package to filter the open files using information from the repository in use.

###### The package options are available through the tab bar context menu and the explanation per option is as follows:

_**Open VCS New Files**_ opens any file that would show up as new by doing a _git status_ in the repository's working directory.

_**Open VCS Modified Files**_ opens any file that would show up as modified by doing a _git status_ in the repository's working directory.

_**Close VCS Unmodified files**_ closes any open file that is not new of modified in the repository and any other files that would not show up by doing a _git status_ in the repository's working directory and the user has not modified.

_**Close VCS Unmodified files to the Right**_ does exactly what _**Close VCS Unmodified files**_ does but acts only to the files on the right of the currently right clicked tab.

_**Keep Only VCS New and Modified Files**_ keeps open only the files marked as new in the repository, as well as any other file that would not show up by doing a _git status_ in the repository's working directory and the user has modified.

_**Keep Only VCS New and Modified Files to the Right**_ does exactly what _**Keep Only VCS New and Modified Files**_ does but acts only to the files on the right of the currently right clicked tab.
