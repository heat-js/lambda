
export default class Joi

	@constructor: (@rules = {}) ->

	@schema = (@fields) ->
		return new Joi

	handle: () ->
		if Array.isArray fields
			schema = {}
			for field in fields
				if rule = app.rules[field]
					schema[field] = rule
				else
					throw new Error "No validation rule found for field: #{field}"

		else if fields instanceof Object
			schema = fields

		else
			throw new TypeError 'Argument fields must be an object or array'

		return (app, next) ->
			ctx.input = await app.joi.validate app.input, schema
			await next()
