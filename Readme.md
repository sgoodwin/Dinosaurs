Dinosaurs is a command line application that I hacked together in an evening. It serves a few purposes:

1. Let me play with Codeable and URLSession without any libraries added.
2. Get data about my subscriptions in my feed-service of choice, Feedwrangler.

Dinosaurs was the name of an awesome feature in NetNewsWire back when it was the king of feeds. It attemped to identify feeds that were dead or rarely updated as well as feeds you didn't read much. It was handy.

In theory this kind of unsubscribing from old junk is less important now since a server is typically checking your feeds and not your app on your computer (where having 400 feeds meant bandwidth consumed and time taken on your home internet which was slower back then).
I thought it would still be useful to clean up my list before I exported my subscription list to share with people.

If you happen to also care at all, here it is. Do whatever with it. Send PR's if you think you made it better, keep it for yourself if you want, that's fine too.

Enjoy!

Oh it's also a nifty example of how to exhaustively consume a paged API (rather than paging in data as needed), I had about 30k items to fetch, but Feedwrangler's API only fetches 100 at a time, so it accumulates the results and does work once the API is exhausted.
