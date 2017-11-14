//
//  main.swift
//  Dinosaurs
//
//  Created by Samuel Ryan Goodwin on 11/14/17.
//  Copyright © 2017 Roundwall Software. All rights reserved.
//

import Foundation

struct Feed: Codable, Hashable {
    static func ==(lhs: Feed, rhs: Feed) -> Bool {
        return lhs.feed_id == rhs.feed_id
    }
    
    let title: String
    let feed_id: Int
    let feed_url: String
    
    var hashValue: Int {
        return feed_id
    }
}

struct FeedItem: Codable {
    let feed_id: Int
    let published_at: Int
    let title: String
    let starred: Bool
}

struct AuthorizeResponse: Codable {
    let access_token: String
    let feeds: [Feed]
}

struct FeedItemsResponse: Codable {
    static func + (lhs: FeedItemsResponse, rhs: FeedItemsResponse) -> FeedItemsResponse {
        return FeedItemsResponse(count: lhs.count + rhs.count, feed_items: lhs.feed_items + rhs.feed_items)
    }
    
    let count: Int
    let feed_items: [FeedItem]
}

print("I will find your dinosaur feeds!")

let email = CommandLine.arguments[1]
let password = CommandLine.arguments[2]
let path = NSString(string: "~/.dinosaurs").expandingTildeInPath

let session = URLSession.shared
let baseURL = URL(string: "https://feedwrangler.net/api/v2/")!

func runStats() {
    let decoder = JSONDecoder()
    let data = try! Data(contentsOf: URL(fileURLWithPath: path))
    let feedsToItem = try! decoder.decode([Feed: [FeedItem]].self, from: data)
    
    print("You subscribed to \(feedsToItem.keys.count) RSS feeds\n\n")
    
    print("Your 10 least updated feeds are:")
    let sorted = feedsToItem.sorted(by: { $0.value.count < $1.value.count })
    let limit = 20
    for (i, line) in sorted[0..<(sorted.count > limit ? limit : sorted.count)].enumerated() {
        print("\(i+1): \(line.key.title) has \(line.value.count)")
    }
}

func saveFeeds(_ feeds: [Feed], items: [FeedItem]) {
    var feedsToItems = [Feed : [FeedItem]]()
    
    for feed in feeds {
        feedsToItems[feed] = []
    }
    
    for item in items {
        let feed = feedsToItems.keys.first(where: { $0.feed_id == item.feed_id })!
        feedsToItems[feed]?.append(item)
    }
    
    let encoder = JSONEncoder()
    do {
        let data = try encoder.encode(feedsToItems)
        try data.write(to: URL(fileURLWithPath: path), options: .atomic)
    } catch {
        print(error.localizedDescription)
    }
    print("Saved")
}

func fetchSinceJanuary(auth: AuthorizeResponse, previousItems: FeedItemsResponse = FeedItemsResponse(count: 0, feed_items: [])) {
    var januaryComponents = Calendar.current.dateComponents(in: TimeZone.current, from: Date())
    januaryComponents.month = 1
    januaryComponents.day = 1
    januaryComponents.hour = 0
    januaryComponents.minute = 0
    januaryComponents.second = 0
    let january = Calendar.current.date(from: januaryComponents)!
    
    let itemsSinceJanuary = Fetch<FeedItemsResponse>(path: "feed_items/list", queryItems: [
        URLQueryItem(name: "access_token", value: auth.access_token),
        URLQueryItem(name: "updated_since", value: january.timeIntervalSinceReferenceDate.description),
        URLQueryItem(name: "offset", value: previousItems.count.description)
        ])
    itemsSinceJanuary.fetch(completion: { (items) in
        let current = previousItems + items
        
        if items.count == 0 {
            // The API will only give us a max of 100 items at a time, so we can't process until we try to get
            // feed items and get 0 feeds back
            print("All set, saving \(current.feed_items.count) feed items")
            saveFeeds(auth.feeds, items: current.feed_items)
        } else {
            // Accumulate the most recent items with the previous batch and fetch again.
            // This will skip these items and ask for the next back
            print("\(current.count) items so far, \(items.count) from last request, fetching more")
            fetchSinceJanuary(auth: auth, previousItems: current)
        }
    })
}

func download() {
    let login = Fetch<AuthorizeResponse>(path: "users/authorize", queryItems: [
        URLQueryItem(name: "email", value: email),
        URLQueryItem(name: "password", value: password),
        URLQueryItem(name: "client_key", value: "28f4c97e2f3061613d39e12c6d0bdb0f")
        ])
    login.fetch { (auth) in
        print("\(auth.feeds.count) feeds")
        
        fetchSinceJanuary(auth: auth)
    }
}

if FileManager.default.fileExists(atPath: path) {
    runStats()
} else {
    print("No data yet, downloading feed history")
    download()
    RunLoop.main.run()
}




