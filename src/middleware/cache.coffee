
singleton = null

export default class CacheMiddleware

	constructor: (@maxMemoryUsageRatio = 2 / 3) ->

	handle: (app, next) ->

		app.cache = =>
			if not singleton
				limit = app.context.memoryLimitInMB or 128
				limit = limit * @maxMemoryUsageRatio
				singleton = new Cache limit

			return singleton

		await next()

export class Cache
	constructor: (@memoryLimit = 128) ->
		@index = []
		@store = new Map

	isOutOfMemory: ->
		rss = if process.memoryUsage.rss then process.memoryUsage.rss() else process.memoryUsage().rss
		rss = rss / ( 1024 * 1024 )

		return rss > @memoryLimit

	get: (key, initialValue = undefined) ->
		if not @has key
			return initialValue

		value = @store.get key
		if typeof value is 'undefined'
			return value

		return JSON.parse value

	has: (key) ->
		return @store.has key

	set: (key, value) ->
		if @isOutOfMemory()
			oldestKey = @index[ 0 ]
			@delete oldestKey

		if not @index.includes key
			@index.push key

		json = JSON.stringify value
		@store.set key, json

	delete: (key) ->
		index = @index.indexOf key
		if index > -1
			@index.splice index, 1

		@store.delete key

	size: ->
		return @store.size
