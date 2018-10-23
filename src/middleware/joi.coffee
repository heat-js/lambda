
import Middleware 	from './abstract'
import Validator 	from '../validator'
import joi 			from 'joi'

export default class Joi extends Middleware

	constructor: (@fields) ->
		super()

	handle: (app, next) ->

		app.joi = ->
			rules = if app.has 'rules' then app.rules else {}
			return new Validator joi, rules

		app.validate = ->
			return app.joi.validate.bind app.joi

		if @fields
			data = await app.joi.validate app.input, @fields
			app.value 'input', data

		await next()
