//
//  Queued.swift
//  Karaoke Kompanion
//
//  Created by Michael Smith on 7/11/15.
//  Copyright (c) 2015 Simple Things. All rights reserved.
//

import Foundation
import JSONJoy

struct Queued : JSONJoy {
    let title: String?
    let artist: String?

    let play_id: String?
    let position: Int?
    let duration: Int?
    let song_id: Int?
    let paused: String?

    init(_ decoder: JSONDecoder) {
        title = decoder["title"].string
        artist = decoder["artist"].string

        play_id = decoder["play_id"].string
        position = decoder["position"].integer
        duration = decoder["duration"].integer
        song_id = decoder["song_id"].integer
        paused = decoder["paused"].string
    }
}