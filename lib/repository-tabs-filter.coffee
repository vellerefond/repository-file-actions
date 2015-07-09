lib = require './repository-tabs-filter-lib'

globals = repositoryTabsFilterInitialized: false

module.exports =
	activate: (state) ->
		setTimeout (=> @initialize state), 0

	initialize: (state) ->
		return if globals.repositoryTabsFilterInitialized
		globals.repositoryTabsFilterInitialized = true
		atom.commands.add 'atom-workspace', 'repository-tabs-filter:close-repository-user-unmodified-files', => @closeRepositoryUserUnmodifiedFiles()
		atom.commands.add 'atom-workspace', 'repository-tabs-filter:close-right-repository-user-unmodified-files', => @closeRepositoryUserUnmodifiedFiles true
		atom.commands.add 'atom-workspace', 'repository-tabs-filter:keep-only-repository-new-user-modified-files', => @keepOnlyRepositoryNewUserModifiedFiles()
		atom.commands.add 'atom-workspace', 'repository-tabs-filter:keep-only-right-repository-new-user-modified-files', =>
			@keepOnlyRepositoryNewUserModifiedFiles true
		atom.commands.add 'atom-workspace', 'repository-tabs-filter:open-repository-new-files', => @openRepositoryNewFiles()
		atom.commands.add 'atom-workspace', 'repository-tabs-filter:open-repository-modified-files', => @openRepositoryModifiedFiles()

	closeRepositoryUserUnmodifiedFiles: (toTheRight) ->
		lib.getFileStatuses().then (fileStatuses) ->
			return unless fileStatuses.length
			minimumBufferIndex = 0
			if toTheRight
				currentBuffer = atom.workspace.getActiveTextEditor()?.buffer
				if currentBuffer
					atom.project.buffers.some (buffer, index) ->
						return false unless currentBuffer is buffer
						minimumBufferIndex = index + 1
						true
			fileStatuses = fileStatuses.filter (fileStatus) -> fileStatus.buffer and (fileStatus.noStatus or fileStatus.isUnmodified)
			atom.workspace.getPanes().forEach (pane) ->
				pane.getItems().filter((item, index) -> index >= minimumBufferIndex && item.buffer and item.buffer.file).forEach (item) ->
					fileStatuses.some (fileStatus) ->
						return false unless item.buffer.file.path is fileStatus.buffer.file.path and not item.buffer.isModified()
						pane.destroyItem item
						true

	keepOnlyRepositoryNewUserModifiedFiles: (toTheRight) ->
		lib.getFileStatuses().then (fileStatuses) ->
			return unless fileStatuses.length
			minimumBufferIndex = 0
			if toTheRight
				currentBuffer = atom.workspace.getActiveTextEditor()?.buffer
				if currentBuffer
					atom.project.buffers.some (buffer, index) ->
						return false unless currentBuffer is buffer
						minimumBufferIndex = index + 1
						true
			fileStatuses = fileStatuses.filter (fileStatus) -> fileStatus.buffer and (fileStatus.noStatus or not fileStatus.isNew)
			atom.workspace.getPanes().forEach (pane) ->
				pane.getItems().filter((item, index) -> index >= minimumBufferIndex && item.buffer and item.buffer.file).forEach (item) ->
					fileStatuses.some (fileStatus) ->
						return false unless item.buffer.file.path is fileStatus.buffer.file.path and not item.buffer.isModified()
						pane.destroyItem item
						true

	openRepositoryNewFiles: ->
		lib.getFileStatuses().then (fileStatuses) ->
			_q = require 'q'
			defer = _q.defer()
			defer.resolve()
			promise = defer.promise
			return promise unless fileStatuses.length
			fileStatuses.filter((fileStatus) -> not fileStatus.buffer and fileStatus.isFile and fileStatus.isNew).forEach (fileStatus) ->
				promise = promise.finally ((filePath) -> atom.workspace.open filePath).bind null, fileStatus.filePath
			promise

	openRepositoryModifiedFiles: ->
		lib.getFileStatuses().then (fileStatuses) ->
			_q = require 'q'
			defer = _q.defer()
			defer.resolve()
			promise = defer.promise
			return promise unless fileStatuses.length
			fileStatuses.filter((fileStatus) -> not fileStatus.buffer and fileStatus.isFile and fileStatus.isModified).forEach (fileStatus) ->
				promise = promise.finally ((filePath) -> atom.workspace.open filePath).bind null, fileStatus.filePath
			promise
