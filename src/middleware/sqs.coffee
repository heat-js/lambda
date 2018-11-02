

import Middleware 	from './abstract'
import AWS			from 'aws-sdk'

export default class SqsMiddleware extends Middleware

	handle: (app, next) ->

		app.sqs = ->
			client = new AWS.SQS {
				apiVersion: '2012-11-05'
				region: app.config.aws.region
			}

			nameResolver = new SqsNameResolver client

			return new Sqs client, nameResolver

		await next()


export class Sqs

	constructor: (@sqsClient, @sqsNameResolver) ->
		@cache = new Map

	send: (service, name, payload) ->
		url = await @sqsNameResolver.url "#{service}__#{name}"

		return @sqsClient.sendMessage({
			QueueUrl: 		url
			MessageBody: 	JSON.stringify payload
			DelaySeconds: 	0
		}).promise()

	batch: (service, name, payloads = []) ->
		entries = payloads.map (payload, index) ->
			return {
				Id: 			String index
				MessageBody: 	JSON.stringify payload
				DelaySeconds: 	0
			}

		promises	= []
		chunks 		= @splitEntriesIntoChunks entries
		url 		= await @sqsNameResolver.url "#{service}__#{name}"

		await Promise.all chunks.map (entries) ->
			return @sqsClient.sendMessageBatch({
				QueueUrl: 	url
				Entries: 	entries
			}).promise()

	splitEntriesIntoChunks: (entries, size = 10) ->
		chunkes = []
		while entries.length > 0
			chunkes.push entries.splice 0, size

		return chunkes


export class SqsNameResolver

	constructor: (@sqsClient) ->
		@urls 		= new Map
		@promises 	= new Map

	url: (name) ->
		if @urls.has name
			return @urls.get name

		if @promises.has name
			{ QueueUrl } = await @promises.get name
			return QueueUrl

		request = @sqsClient.getQueueUrl {
			QueueName: name
		}

		promise = request.promise()
		@promises.set name, promise

		{ QueueUrl } = await promise

		@urls.set name, QueueUrl
		return QueueUrl
