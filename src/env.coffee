export get = (name, defaultValue) ->
	value = process.env[name]

	if typeof value is 'undefined'
		return defaultValue

	return value

export str = (name, defaultValue) ->
	value = @get name, defaultValue

	return String value

export int = (name, defaultValue) ->
	value = @get name, defaultValue

	return parseInt value, 10

export float = (name, defaultValue) ->
	value = @get name, defaultValue

	return parseFloat value

export bool = (name, defaultValue) ->
	value = @get name, defaultValue

	switch value
		when 'true', 'TRUE', 'yes', '1'
			return true

		when 'false', 'FALSE', 'no', '0'
			return false

	return value

export array = (name, defaultValue, sep = ',') ->
	value = @get name, defaultValue

	if Array.isArray value
		return value

	array = value.split sep
	array = array.map (item) -> item.trim()

	return array

export default {
	get
	str
	string: str
	int
	integer: int
	float
	bool
	boolean: bool
	array
}
