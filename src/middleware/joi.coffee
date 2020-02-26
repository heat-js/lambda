
import Middleware 		from './abstract'
import ValidationError 	from '../error/validation-error'
import joi 				from '@hapi/joi'

export default class Joi extends Middleware

	constructor: (@fields) ->
		super()

	handle: (app, next) ->

		app.joi = ->
			rules  = if app.has 'rules' then app.rules else {}
			errorMessages = if app.has 'errorMessages' then app.errorMessages else {}

			return new Validator joi, rules, errorMessages

		app.validate = ->
			return app.joi.validate.bind app.joi

		if @fields
			data = await app.joi.validate app.input, @fields
			app.value 'input', data

		await next()


export class Validator

	constructor: (@validator, @rules, @errorMessages) ->

	validate: (input, fields, options) ->

		schema = @getValidationSchema fields

		try
			return await @validator.validate input, schema, options
		catch error
			message = @customErrorMessages error

			throw new ValidationError message

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

	customErrorMessages: (error) ->
		if not Array.isArray error.details
			return error.message

		details = error.details[0]
		context = details.context
		custom  = @errorMessages

		for path in details.path
			custom = custom[path]

			if not custom
				return details.message

		[type, key] = details.type.split '.'

		if not custom = custom[type]
			return error.message

		if not custom = custom[key]
			return error.message

		if typeof custom is 'string'
			return custom

		return custom context
