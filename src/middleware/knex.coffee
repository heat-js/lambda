
import Middleware 	from './abstract'
import knex 		from 'knex'

export default class Knex extends Middleware

	handle: (app, next) ->

		options = if driver = app.config.knex.driver
			app.config.knex[driver]
		else
			app.config.knex

		db = knex options

		app.value 'knex', db

		try
			await next()

		catch error
			db.destroy()
			throw error

		db.destroy()
