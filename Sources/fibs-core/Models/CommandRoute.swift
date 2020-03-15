//
//  File.swift
//  
//
//  Created by Szymon Mrozek on 15/03/2020.
//

import Foundation

struct CommandRoute {
    struct RequestBody: Decodable {
        let command: String
    }
    
    struct ResponseBody: Encodable {
        private enum CodingKeys: String, CodingKey {
            case rawResponse = "raw_response"
        }
        
        let rawResponse: String
    }
}
