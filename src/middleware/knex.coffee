
export default class Knex

	handle: (app, next) ->
		db = app.db

		try
			await next()
		catch error
			db.destroy()
			throw error

		db.destroy()
