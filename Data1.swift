//
//  Data.swift
//  URL Shortener
//

//

import Foundation

class Data1: Decodable {
    
    var domain: String
    var alias: String
    var created_at: String
    var expires_at: String
    var tiny_url: String
    var hits: Int
    var url: String
}
