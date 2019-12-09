
import Middleware 		from './abstract'
import ValidationError 	from '../error/validation-error'
import joi 				from '@hapi/joi'

export default class Joi extends Middleware

	constructor: (@fields) ->
		super()

	handle: (app, next) ->

		app.joi = ->
			rules  = if app.has 'rules' then app.rules else {}
			errMsg = if app.has 'errorMessages' then app.errorMessages else {}

			return new Validator joi, rules, errMsg

		app.validate = ->
			return app.joi.validate.bind app.joi

		if @fields
			data = await app.joi.validate app.input, @fields
			app.value 'input', data

		await next()


export class Validator

	constructor: (@validator, @rules, @errorMessages) ->

	validate: (input, fields) ->

		schema = @getValidationSchema fields
		schema = @customErrorMessages schema

		try
			return await @validator.validate input, schema
		catch error
			if error.details? and Array.isArray error.details
				message = error.details[0].message
			else
				message = error.message

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

	customErrorMessages: (schema) ->
		for field, errorTypes of @errorMessages
			item = schema[field]

			if not item
				throw new Error 'No validation rule found for field: ' + field

			item.error (errors) ->
				for error in errors
					custom = errorTypes[error.type]

					if not custom
						continue

					if typeof custom is 'string'
						error.message = custom
					else
						error.message = custom error

				return errors

		return schema
