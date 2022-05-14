//
//  EmojiArtModel.Background.swift
//  EmojiArt
//
//  Created by stephen on 2022/05/07.
//

import Foundation

extension EmojiArtModel {
    enum Background : Equatable, Codable {  //Can't add Codable when there's associated data
        case blank
        case url(URL)   //associated data
        case imageData(Data)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let url = try? container.decode(URL.self, forKey: .url) { //if because don't wnt throw.
                self = .url(url)
            } else if let imageData = try? container.decode(Data.self, forKey: .imageData) {
                self = .imageData(imageData)
            } else {
                self = .blank
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case url  = "theURL"
            case imageData
            
//            val var rawValue: String or init rawValue
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .url(let url): try container.encode(url, forKey: .url)
            case .imageData(let data): try container.encode(data, forKey: .imageData)
            case .blank: break
            }
        }
        
        
        var url: URL? {
            switch self {
            case .url(let url): return url
            default: return nil
            }
        }
        
        var imageData: Data? {
            switch self {
            case .imageData(let data): return data
            default: return nil
            }
        }
    }
}
