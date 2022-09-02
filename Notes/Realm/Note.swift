//
//  Note.swift
//  Note
//
//  Created by SC on 2022/09/02.
//

import Foundation
import RealmSwift

class Note: Object {
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var writeDate = Date()  // 작성일(필수)
    @Persisted var editDate = Date()   // 수정일(필수)
    @Persisted var title: String       // 제목(필수)
    @Persisted var contents: String?   // 내용(추가 텍스트)(옵션)
    @Persisted var isPinned: Bool      // 고정 여부(필수)
    
    convenience init(title: String, contents: String?) {
        self.init()
        self.writeDate = Date()
        self.editDate = Date()
        self.title = title
        self.contents = contents
        self.isPinned = false
    }
}
