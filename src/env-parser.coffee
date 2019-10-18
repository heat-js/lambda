
export class EnvParser

	constructor: (@data) ->
		@string 	= @str
		@integer 	= @int
		@boolean 	= @bool

	testingEnv: ->
		return !!(
			process.env.JEST_WORKER_ID or
			process.env.TESTING
		)

	get:(name, defaultValue) ->
		value = @data[name]

		if typeof value isnt 'undefined'
			return value

		if typeof defaultValue isnt 'undefined'
			return defaultValue

		if @testingEnv()
			return ''

		throw new TypeError [
			'Environment variable '
			name
			' hasn\'t been set.'
		].join '"'

	str: (name, defaultValue) ->
		value = @get name, defaultValue

		return String value

	int: (name, defaultValue) ->
		value = @get name, defaultValue

		return parseInt value, 10

	float: (name, defaultValue) ->
		value = @get name, defaultValue

		return parseFloat value

	bool: (name, defaultValue) ->
		value = @get name, defaultValue

		switch value
			when 'true', 'TRUE', 'yes', '1'
				return true

			when 'false', 'FALSE', 'no', '0'
				return false

		return !!value

	array: (name, defaultValue, sep = ',') ->
		value = @get name, defaultValue

		if Array.isArray value
			return value

		array = value.split sep
		array = array.map (item) -> item.trim()

		return array

	enum: (name, possibilities, defaultValue) ->

		value = @get name, defaultValue

		if not possibilities.includes value
			throw new TypeError [
				'Environment variable '
				name
				' must contain one of the following values: '
				possibilities.join ', '
				'.'
			].join ''

		return value


export default new EnvParser process.env
