
import Middleware 	from './abstract'
import AWS			from 'aws-sdk'

export default class StepFunctionsMiddleware extends Middleware

	region: (app) ->
		return (
			app.has('config') and
			app.config.aws and
			app.config.aws.region
		) or (
			process.env.AWS_REGION
		) or (
			'eu-west-1'
		)

	accountId: (app) ->
		return (
			app.has('config') and
			app.config.aws and
			app.config.aws.accountId
		) or (
			process.env.AWS_ACCOUNT_ID
		)

	handle: (app, next) ->

		app.stepFunctions = =>

			region 		= @region app
			accountId 	= @accountId app

			client = new AWS.StepFunctions {
				apiVersion: '2016-11-23'
			}

			return new StepFunctions(
				client
				region
				accoundId
			)

		await next()


export class StepFunctions

	constructor: (@client, @region, @accountId) ->

	start: (service, name, payload, idempotentKey = null) ->

		arn = [
			'arn:aws:states'
			@region
			@accountId
			'stateMachine'
			"#{service}__#{name}"
		].join ':'

		return @client.startExecution {
			stateMachineArn: 	arn
			input: 				JSON.stringify payload
			name: 				idempotentKey
		}
		.promise()
