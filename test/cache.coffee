
import { Cache } from '../src/middleware/cache'

describe 'Cache Middleware', ->

	cache = new Cache

	it 'should have correct initial behavior', ->
		expect cache.size()
			.toBe 0

		expect cache.has 'key'
			.toBe false

		expect cache.get 'key'
			.toBe undefined

	it 'should have correct size', ->
		cache.set 'key', true
		expect cache.size()
			.toBe 1

	it 'should set entry', ->
		values = [
			undefined
			null
			1
			0
			-1
			'string'
			new Array
			new Object
		]

		for value, index in values
			key = "key-#{ index }"
			cache.set key, value

			expect cache.has key
				.toBe true

			expect cache.get key
				.toStrictEqual value

		return

	it 'should delete entry', ->
		cache.set 'key', true
		expect cache.has 'key'
			.toBe true

		cache.delete 'key'
		expect cache.has 'key'
			.toBe false

	it 'should get copy of the data', ->
		value = {}
		cache.set 'key', value

		expect cache.get 'key'
			.not.toBe value

	it 'should remove values after memory limit is reached', ->
		cache = new Cache 1
		cache.set 'key-1', true

		expect cache.size()
			.toBe 1

		cache.set 'key-2', true

		expect cache.size()
			.toBe 1

		expect cache.has 'key-1'
			.toBe false

	# it 'should throw on invalid values', ->
	# 	class TestClass

	# 	values = [
	# 		->
	# 		=>
	# 		TestClass
	# 		new TestClass
	# 	]

	# 	for value, index in values
	# 		key = "key-#{ index }"
	# 		cache.set key, value

	# 		# expect cache.has key
	# 		# 	.toBe true

	# 		console.log	index, cache.get key

	# 		# expect cache.get key
	# 		# 	.toStrictEqual value

	# 	return
