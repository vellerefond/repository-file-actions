lib = require './repository-file-actions-lib'

globals = repositoryFileActionsInitialized: false

module.exports =
	activate: (state) ->
		setTimeout (=> @initialize state), 0

	initialize: (state) ->
		return unless atom.packages.getLoadedPackage 'tabs'
		return if globals.repositoryFileActionsInitialized
		globals.repositoryFileActionsInitialized = true
		atom.commands.add 'atom-workspace', 'repository-file-actions:close-repository-unmodified-user-unmodified-files', =>
			@closeRepositoryUnmodifiedUserUnmodifiedFiles()
		atom.commands.add 'atom-workspace', 'repository-file-actions:close-right-repository-unmodified-user-unmodified-files', =>
			@closeRepositoryUnmodifiedUserUnmodifiedFiles true
		atom.commands.add 'atom-workspace', 'repository-file-actions:keep-only-repository-new-modified-user-modified-files', =>
			@keepOnlyRepositoryNewModifiedUserModifiedFiles()
		atom.commands.add 'atom-workspace', 'repository-file-actions:keep-only-right-repository-new-modified-user-modified-files', =>
			@keepOnlyRepositoryNewModifiedUserModifiedFiles true
		atom.commands.add 'atom-workspace', 'repository-file-actions:open-repository-new-files', => @openRepositoryNewFiles()
		atom.commands.add 'atom-workspace', 'repository-file-actions:open-repository-modified-files', => @openRepositoryModifiedFiles()

	closeRepositoryUnmodifiedUserUnmodifiedFiles: (toTheRight) ->
		lib.getFileStatuses().then (fileStatuses) ->
			return unless fileStatuses.length
			minimumBufferIndex = 0
			if toTheRight
				currentBuffer = require('atom-space-pen-views').jQuery('.tab.right-clicked')[0].item.buffer
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

	keepOnlyRepositoryNewModifiedUserModifiedFiles: (toTheRight) ->
		lib.getFileStatuses().then (fileStatuses) ->
			return unless fileStatuses.length
			minimumBufferIndex = 0
			if toTheRight
				currentBuffer = require('atom-space-pen-views').jQuery('.tab.right-clicked')[0].item.buffer
				if currentBuffer
					atom.project.buffers.some (buffer, index) ->
						return false unless currentBuffer is buffer
						minimumBufferIndex = index + 1
						true
			fileStatuses = fileStatuses.filter (fileStatus) -> fileStatus.buffer and (fileStatus.noStatus or not (fileStatus.isNew or fileStatus.isModified))
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
