
import Middleware 	from './abstract'
import AWS			from 'aws-sdk'

export default class SqsMiddleware extends Middleware

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

	handle: (app, next) ->

		app.sqsClient = =>
			return new AWS.SQS {
				apiVersion: '2012-11-05'
				region: 	@region app
			}

		app.sqsNameResolver = ->
			return new SqsNameResolver app.sqsClient

		app.sqs = ->
			return new Sqs app.sqsClient, app.sqsNameResolver

		await next()


export class Sqs

	constructor: (@client, @sqsNameResolver) ->
		@cache = new Map

	send: (service, name, payload, delay = 0) ->
		url = await @sqsNameResolver.url "#{service}__#{name}"

		return @client.sendMessage({
			QueueUrl: 		url
			MessageBody: 	JSON.stringify payload
			DelaySeconds: 	delay
		}).promise()

	batch: (service, name, payloads = [], delay = 0) ->
		entries = payloads.map (payload, index) ->
			return {
				Id: 			String index
				MessageBody: 	JSON.stringify payload
				DelaySeconds: 	delay
			}

		url 	= await @sqsNameResolver.url "#{service}__#{name}"
		chunks 	= @chunk entries

		return Promise.all chunks.map (entries) =>
			return @client.sendMessageBatch({
				QueueUrl: 	url
				Entries: 	entries
			}).promise()

	chunk: (entries, size = 10) ->
		chunks = []
		while entries.length > 0
			chunks.push entries.splice 0, size

		return chunks


export class SqsNameResolver

	constructor: (@client) ->
		@urls 		= new Map
		@promises 	= new Map

	url: (name) ->
		if @urls.has name
			return @urls.get name

		if @promises.has name
			{ QueueUrl } = await @promises.get name
			return QueueUrl

		promise = @client.getQueueUrl { QueueName: name }
			.promise()

		@promises.set name, promise
		{ QueueUrl } = await promise

		@urls.set name, QueueUrl

		return QueueUrl
