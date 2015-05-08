names = ["chet", "joe", "charlie"]

Meteor.startup ->
  if Players.find().count() is 0
    for name in names
      Players.insert({name})

class CursorObserver
  constructor: (@sub, @collection, @key, @getCursor) ->
    @ids = []
    @handle = null
    @sub.onStop =>
      @handle?.stop?()

  observe: (newIds) ->
    # remove the stale docs
    removeIds = R.difference(@ids, newIds)
    for id in removeIds
      @sub.removed(@collection, id)

    # don't add the same doc twice!
    addIds = R.difference(newIds, @ids)
    cursor = @getCursor(newIds)

    @handle?.stop?()
    @handle = cursor.observeChanges 
      added: (id, fields) =>
        if R.contains(id, addIds)
          fields[@key] = true
          @sub.added(@collection, id, fields)
      changed: (id, fields) =>
        @sub.changed(@collection, id, fields)
      removed: (id) =>
        @sub.removed(@collection, id)
    
    @ids = newIds

getPlayersCursor = (x) ->
  Players.find({_id:{$in:x}})

names2Ids = (x) ->
  _.pluck(Players.find({name:{$in:x}}, {fields:{_id:1}}).fetch(), '_id')

Meteor.publish 'feed1', ->
  observer = new CursorObserver(this, 'players', 'feed1', getPlayersCursor)
  observer.observe names2Ids(["chet", "joe", "charlie"])
  @ready()
  return

Meteor.publish 'feed2', ->
  observer = new CursorObserver(this, 'players', 'feed2', getPlayersCursor)
  observer.observe names2Ids(["chet", "joe"])
  @ready()
  delay 1000, ->
    observer.observe names2Ids(["joe", "charlie"])
  return