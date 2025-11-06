//
//  VocabularyItemExt.swift
//  YLE X
//
//  Created by Tenaity on 6/11/25.
//

import Foundation

extension VocabularyItem {
    init(word: String,
         meaning: String,
         example: String? = nil,
         imageName: String? = nil,
         audioName: String? = nil,
         level: YLELevel,
         topic: String) {
        
        self.init(id: UUID().uuidString,
                          word: word,
                          meaning: meaning,
                          example: example,
                          imageName: imageName,
                          audioName: audioName,
                          level: level,
                          topic: topic)
    }
}
