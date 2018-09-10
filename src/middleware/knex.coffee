
import Middleware 	from './abstract'
import KnexClass 	from 'knex'

export default class Knex extends Middleware

	handle: (app, next) ->

		db = app.knex = new KnexClass app.config.knex

		try
			await next()

		catch error
			db.destroy()
			throw error

		db.destroy()
