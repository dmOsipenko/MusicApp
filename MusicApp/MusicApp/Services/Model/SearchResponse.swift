//
//  SearchResponse.swift
//  MusicApp
//
//  Created by Дмитрий Осипенко on 29.08.21.
//

import UIKit
import ObjectMapper


struct SearchResponse: Mappable {
    
    var resultCount: Int?
    var results: [Track]?
    
    init?(map: Map) {
       mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        resultCount  <- map["resultCount"]
        results      <- map["results"]
    }
}

struct Track: Mappable {
    var artistName: String?
    var collectionName: String?
    var trackName: String?
    var artworkUrl100: String?
    var previewUrl: String?
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        artistName       <- map["artistName"]
        collectionName   <- map["collectionName"]
        trackName        <- map["trackName"]
        artworkUrl100    <- map["artworkUrl100"]
        previewUrl       <- map["previewUrl"]
        
    }
}


