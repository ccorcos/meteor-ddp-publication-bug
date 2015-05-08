# DDP Publication Bug

## Motivation

Suppose you use a REST API to determine which Mongo documents to display in a feed. In a publication, you poll the API, diff the results, and publish them to the client.

Now suppose you have multiple feeds that publish the same type of document. To determine which feed the documents belong in, we can add a boolean value to the documents as they are published.

## Bug

This is a very contrived example to pinpoint the issue. On the client, we subscribe to feed1. One second later, we subscribe to feed2. One second later, we create a new observer in the feed2 publication representing a poll and diff with new results. One second later, we unsubscribe from feed2.

To run this example, simple press the "run bug" button. You'll notice that after we unsubscribe from feed2, there is still one document ("joe") that has a `{feed2: true}` property while the others have had the property removed. 

Using the [ddp-analyzer-proxy](https://github.com/arunoda/meteor-ddp-analyzer), I've logged all the DDP messages when running the bug. "chet" and "charlie" have had feed2 cleared, but "joe" has not. I'm not sure why this is, but it appears to be due to the fact that we are changing the oberver within the publication.


```
OUT  {"msg":"sub","id":"64up33A53FZ3XWpTS","name":"feed1","params":[]}
IN   {"msg":"added","collection":"players","id":"J6xpSXMZLXRJMZzGh","fields":{"name":"chet","feed1":true}}
IN   {"msg":"added","collection":"players","id":"Rk86XMZZ2jLKedYX4","fields":{"name":"joe","feed1":true}}
IN   {"msg":"added","collection":"players","id":"P3SC4Z3vHDJXQTWMT","fields":{"name":"charlie","feed1":true}}
IN   {"msg":"ready","subs":["64up33A53FZ3XWpTS"]}
OUT  {"msg":"sub","id":"SWncTtwnr5WSQ8X48","name":"feed2","params":[]}
IN   {"msg":"changed","collection":"players","id":"J6xpSXMZLXRJMZzGh","fields":{"feed2":true}}
IN   {"msg":"changed","collection":"players","id":"Rk86XMZZ2jLKedYX4","fields":{"feed2":true}}
IN   {"msg":"ready","subs":["SWncTtwnr5WSQ8X48"]}
IN   {"msg":"changed","collection":"players","id":"P3SC4Z3vHDJXQTWMT","fields":{"feed2":true}}
OUT  {"msg":"unsub","id":"SWncTtwnr5WSQ8X48"}
IN   {"msg":"changed","collection":"players","id":"J6xpSXMZLXRJMZzGh","cleared":["feed2"]}
IN   {"msg":"changed","collection":"players","id":"P3SC4Z3vHDJXQTWMT","cleared":["feed2"]}
IN   {"msg":"nosub","id":"SWncTtwnr5WSQ8X48"}
```

## Update

It appears the problem occurs when I call `sub.added` multiple times for the same document within the same subscription. This occurs when there is overlap between the cursors. Thus, I have made sure to meticulously diff the documents so we don't add the same document twice. This can be seen in the `diff` branch. That said, I would still consider this a bug. If merge-box is efficiently sending only the minimal amount of information, it ought to be able to handle when a single document is added more than once.