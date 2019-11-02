
import Middleware	from './abstract'
import AWS			from 'aws-sdk'

export default class Iot extends Middleware

	endpoint: (app) ->
		return (
			app.has('config') and
			app.config.iot and
			app.config.iot.endpoint
		) or (
			process.env.IOT_ENDPOINT
		) or (
			await @describeEndpoint app
		)

	describeEndpoint: (app) ->
		if not @promise
			@promise = app.iot.describeEndpoint {
				endpointType: 'iot:Data'
			}
			.promise()

		{ endpointAddress } = await @promise
		return endpointAddress

	handle: (app, next) ->
		app.iot = ->
			return new AWS.Iot {
				apiVersion: '2015-05-28'
			}

		endpoint = await @endpoint app

		app.iotData = ->
			return new AWS.IotData {
				endpoint
				apiVersion: '2015-05-28'
			}

		app.pubsub = ->
			return new PubSub app.iotData

		await next()

export class PubSub

	constructor: (@iotData) ->

	publish: ({ topic, id, event, payload, qos }) ->
		data =
			e: event
			v: payload

		if id
			data.i = id

		return @iotData.publish {
			qos: qos or 1
			topic
			payload: JSON.stringify data
		}
		.promise()
