names = ["chet", "joe", "charlie"]

Meteor.startup ->
  if Players.find().count() is 0
    for name in names
      Players.insert({name})

class CursorObserver
  constructor: (@sub, @key, @getCursor) ->
    @ids = []

  query: (newIds) ->
    stale = R.difference(ids, newIds)


    cursor = @getCursor(newIds)

    handle = cursor.observeChanges 
      added: (id, fields) ->
        fields[key] = true
        sub.added('players', id, fields)
      changed: (id, fields) ->
        sub.changed('players', id, fields)
      removed: (id) ->
        sub.removed('players', id)
    
    sub.onStop ->
      handle.stop()

  return handle

Meteor.publish 'feed1', ->
  sub = this
  handle = observeCursor sub, 'feed1', ["chet", "joe", "charlie"]
  sub.ready()
  return

Meteor.publish 'feed2', ->
  sub = this
  handle = observeCursor sub, 'feed2', ["chet", "joe"]
  sub.ready()
  delay 1000, ->
    handle.stop()
    handle = observeCursor sub, 'feed2', ["joe", "charlie"]
  return