module.exports =
	getRepositories: ->
		repositories = []
		_q = require 'q'
		defer = _q.defer()
		defer.resolve()
		promise = defer.promise
		for rootDirectory, rootDirectoryIndex in atom.project.rootDirectories
				promise = promise.then ((repository) ->
					repositories.push rootDirectory: atom.project.rootDirectories[@ - 1], repository: repository
					atom.project.repositoryForDirectory atom.project.rootDirectories[@]
				).bind rootDirectoryIndex
		promise.then (repository) ->
				_defer = _q.defer()
				unless repository
						_defer.resolve []
						return _defer.promise
				repositories.push rootDirectory: atom.project.rootDirectories[atom.project.rootDirectories.length - 1], repository: repository
				repositories.splice 0, 1
				_defer.resolve repositories
				_defer.promise

	getFileStatuses: ->
		@getRepositories().then (dirRepos) ->
				_p = require 'path'
				_q = require 'q'
				result = []
				defer = _q.defer()
				unmatchedRepoPaths = {}
				openUnmatchedRepoPaths = {}
				for dirRepo in dirRepos
						repoStatus = dirRepo.repository.repo.getStatus()
						repoPaths = {}
						Object.keys(repoStatus).forEach (filePath) -> repoPaths[_p.join dirRepo.repository.repo.getWorkingDirectory(), filePath] = repoStatus[filePath]
						Object.keys(repoPaths).forEach (filePath) -> unmatchedRepoPaths[filePath] = repository: dirRepo.repository, status: repoPaths[filePath]
						atom.project.buffers.filter((buffer) -> buffer.file).forEach (buffer, bufferIndex) ->
								delete unmatchedRepoPaths[buffer.file.path]
								unless repoPaths[buffer.file.path]
									openUnmatchedRepoPaths[buffer.file.path] = buffer
									return
								delete openUnmatchedRepoPaths[buffer.file.path]
								isNew = dirRepo.repository.repo.isStatusNew repoPaths[buffer.file.path]
								isModified = dirRepo.repository.repo.isStatusModified repoPaths[buffer.file.path]
								result.push
									filePath: buffer.file.path
									buffer: buffer
									isNew: isNew
									isModified: isModified
									isUnmodified: not isNew and not isModified
									isIgnored: dirRepo.repository.repo.isStatusIgnored repoPaths[buffer.file.path]
									isDeleted: dirRepo.repository.repo.isStatusDeleted repoPaths[buffer.file.path]
									isFile: true
				Object.keys(openUnmatchedRepoPaths).forEach (openUnmatchedRepoPath) ->
					delete unmatchedRepoPaths[openUnmatchedRepoPath]
					result.push
						filePath: openUnmatchedRepoPaths[openUnmatchedRepoPath].file.path
						buffer: openUnmatchedRepoPaths[openUnmatchedRepoPath]
						noStatus: true
						isFile: true
				_fs = require 'fs'
				Object.keys(unmatchedRepoPaths).forEach (unmatchedRepoPath) ->
					statusRepo = unmatchedRepoPaths[unmatchedRepoPath]
					isNew = statusRepo.repository.repo.isStatusNew statusRepo.status
					isModified = statusRepo.repository.repo.isStatusModified statusRepo.status
					stat = if _fs.existsSync unmatchedRepoPath then _fs.statSync unmatchedRepoPath else undefined
					result.push
						filePath: unmatchedRepoPath
						isNew: isNew
						isModified: isModified
						isUnmodified: not isNew and not isModified
						isIgnored: statusRepo.repository.repo.isStatusIgnored statusRepo.status
						isDeleted: statusRepo.repository.repo.isStatusDeleted statusRepo.status
						isFile: if stat then stat.isFile() else false
						isDirectory: if stat then stat.isDirectory() else false
				defer.resolve result
				defer.promise
