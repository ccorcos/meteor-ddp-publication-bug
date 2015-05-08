@Players = new Mongo.Collection("players")

@delay = (ms, f) ->
  Meteor.setTimeout(f, ms)
