
import Middleware 	from './abstract'
import KnexClass 	from 'knex'

export default class Knex extends Middleware

	handle: (app, next) ->
		if driver = app.config.knex.driver
			options = app.config.knex[driver]
		else
			options = app.config.knex

		db = app.knex = new KnexClass options

		try
			await next()

		catch error
			db.destroy()
			throw error

		db.destroy()
