
import Middleware 	from './abstract'
import AWS			from 'aws-sdk'

export default class SnsMiddleware extends Middleware

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

		app.sns = =>
			region 		= @region app
			accountId 	= @accountId app

			client = new AWS.SNS {
				apiVersion: '2016-11-23'
				region
			}

			return new Sns(
				client
				region
				accountId
			)


		await next()


export class Sns

	constructor: (@client) ->

	publish: (service, name, subject, payload, attributes) ->
		arn = [
			'arn:aws:states'
			@region
			@accountId
			'stateMachine'
			"#{service}__#{name}"
		].join ':'

		params = {
			TopicArn: 	arn
			Subject:	subject
		}

		type = typeof payload

		if type is 'object' and payload isnt null
			params.Message = JSON.stringify payload
			params.MessageStructure	= 'json'

		else if type is 'string'
			params.Message = payload

		else
			throw new TypeError 'Invalid SNS message type'

		if attributes and Object.keys(attributes).length
			messageAttributes = {}

			for key, value of attributes
				messageAttributes[key] = {
					DataType: 'String'
					StringValue: value
				}

			params.MessageAttributes = messageAttributes

		return @client.publish params
			.promise()
