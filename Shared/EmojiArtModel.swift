//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by stephen on 2022/05/07.
//

import Foundation

struct EmojiArtModel: Codable {
    var background = Background.blank
    var emojis = [Emoji]()  //Array is Codable but, struct.. -> add Codable in struct
    
    struct Emoji : Identifiable, Hashable, Codable { //Hashable for Set
        let text: String
        var x: Int  //offset from the center. NOT CGFloat, Double ! -> UI Independent
        var y: Int  //offset from the center
        var size: Int
        let id: Int
        
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {    //fileprivate: for id access
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
    
    //MARK: L11 55:09
    
    func json() throws -> Data {
        return try JSONEncoder().encode(self)
        
    }
    
    init(json: Data) throws {
        self = try JSONDecoder().decode(EmojiArtModel.self, from: json)
    }
    
    init(url: URL) throws {
        let data = try Data(contentsOf: url)    //block the queue... but file is fast!
        self = try EmojiArtModel(json: data)
    }
    
    init() { }
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ text: String, at location: (x: Int, y: Int), size: Int) {  //tuple
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: location.x, y: location.y, size: size, id: uniqueEmojiId))
    }
}
