
import ValidationError from './error/validation-error'

export default class Validator

	constructor: (@validator, @rules) ->

	validate: (input, fields) ->
		try
			return await @validator.validate input, @getValidationSchema(fields)
		catch error
			throw new ValidationError error.details[0].message

	getValidationSchema: (fields) ->
		if Array.isArray fields
			schema = {}

			for field in fields
				if rule = @rules[field]
					schema[field] = rule
				else
					throw new Error 'No validation rule found for field: ' + field

		else if fields instanceof Object
			schema = fields

		else
			throw new TypeError 'Argument fields must be an object or array'

		return schema
