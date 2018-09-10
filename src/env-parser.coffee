
export class EnvParser

	constructor: (@data) ->

		@string 	= @str
		@integer 	= @int
		@boolean 	= @bool

	get:(name, defaultValue) ->
		value = @data[name]

		if typeof value is 'undefined'
			return defaultValue

		return value

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

		return value

	array: (name, defaultValue, sep = ',') ->
		value = @get name, defaultValue

		if Array.isArray value
			return value

		array = value.split sep
		array = array.map (item) -> item.trim()

		return array

export default new EnvParser process.env
