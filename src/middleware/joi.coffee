
import Middleware 	from './abstract'
import joi 			from 'joi'

export default class Joi extends Middleware

	@rules = {}

	constructor: (@fields) ->
		super()

	handle: (app, next) ->
		app.input = await joi.validate app.input, @schema app.rules
		await next()

	schema: (rules) ->
		if not @schema_
			if Array.isArray @fields
				@schema_ = {}

				for field in @fields
					if rule = rules[field]
						@schema_[field] = rule
					else
						throw new Error 'No validation rule found for field: ' + field

			else if @fields instanceof Object
				@schema_ = fields

			else
				throw new TypeError 'Argument fields must be an object or array'

		return @schema_
