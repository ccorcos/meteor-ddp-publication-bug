Template.main.helpers
  feed1count: () ->
    Players.find({feed1:true}).count()
  feed2count: () ->
    Players.find({feed2:true}).count()

sub1 = null
sub2 = null
subfeed1 = ->
  sub1 = Meteor.subscribe('feed1')
subfeed2 = ->
  sub2 = Meteor.subscribe('feed2')
unsubfeed1 = ->
  sub1.stop()
unsubfeed2 = ->
  sub2.stop()


Template.main.events
  'click .run': () ->
    subfeed1()
    delay 1000, ->
      subfeed2()
      delay 2000, ->
        unsubfeed2()

  'click .reset': ->
    unsubfeed1()
    unsubfeed2()