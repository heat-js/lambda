

import Middleware 	from './abstract'
import AWS			from 'aws-sdk'

export default class SqsMiddleware extends Middleware

	region: ->
		return (
			app.has('config') and
			app.config.aws and
			app.config.aws.region
		) or (
			process.env.AWS_REGION
		)

	handle: (app, next) ->

		app.sqs = ->
			client = new AWS.SQS {
				apiVersion: '2012-11-05'
				region: 	@region()
			}

			nameResolver = new SqsNameResolver client

			return new Sqs client, nameResolver

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

		chunks 	= @splitEntriesIntoChunks entries
		url 	= await @sqsNameResolver.url "#{service}__#{name}"

		return Promise.all chunks.map (entries) =>
			return @client.sendMessageBatch({
				QueueUrl: 	url
				Entries: 	entries
			}).promise()

	splitEntriesIntoChunks: (entries, size = 10) ->
		chunkes = []
		while entries.length > 0
			chunkes.push entries.splice 0, size

		return chunkes


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
