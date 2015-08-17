//
//  Song.swift
//  Karaoke Kompanion
//
//  Created by Michael Smith on 8/16/15.
//  Copyright © 2015 Simple Things. All rights reserved.
//

import Foundation

struct Song {
    let title: String
    let artist: String

    let id: Int?
    let language: String?
    let play_count: Int?
    let added_on: String?

    init(json: Dictionary<String,AnyObject>) {
        self.title = json["title"] as! String
        self.artist = json["artist"] as! String

        self.id = json["id"] as? Int
        self.language = json["language"] as? String
        self.play_count = json["play_count"] as? Int
        self.added_on = json["added_on"] as? String
    }
}