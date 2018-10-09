
import Middleware from './abstract'

export default class Event extends Middleware

	constructor: (@name) ->

	handle: (app, next) ->

		app.emitter.emit @name

		await next()
