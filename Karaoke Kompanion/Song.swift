//
//  Song.swift
//  Karaoke Kompanion
//
//  Created by Michael Smith on 8/16/15.
//  Copyright © 2015 Simple Things. All rights reserved.
//

import Foundation
import JSONJoy

struct Song : JSONJoy {
    let title: String?
    let artist: String?

    let id: Int?
    let language: String?
    let play_count: Int?
    let added_on: String?

    init(_ decoder: JSONDecoder) {
        title = decoder["title"].string
        artist = decoder["artist"].string

        id = decoder["id"].integer
        language = decoder["language"].string
        play_count = decoder["play_count"].integer
        added_on = decoder["added_on"].string
    }
}