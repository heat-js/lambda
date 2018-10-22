
import Middleware 	from './abstract'
import joi 			from 'joi'

export default class Joi extends Middleware

	constructor: (@fields) ->
		super()

	handle: (app, next) ->

		@rules = app.rules

		if @fields

			data = await joi.validate(
				app.input
				@schema @fields
			)

			app.value 'input', data

		app.value 'validate', @validate.bind @

		await next()

	validate: (input, fields) ->
		return joi.validate(
			input
			@schema fields
		)

	schema: (fields) ->

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
