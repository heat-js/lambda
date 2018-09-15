
import Middleware 	from './abstract'
import knex 		from 'knex'

export default class Knex extends Middleware

	handle: (app, next) ->

		db = knex app.config.knex

		app.value 'knex', db

		try
			await next()

		catch error
			db.destroy()
			throw error

		db.destroy()
