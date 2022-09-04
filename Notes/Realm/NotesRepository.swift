//
//  NotesRepository.swift
//  Notes
//
//  Created by SC on 2022/09/02.
//

import Foundation
import RealmSwift

protocol RealmProtocol {
    func fetch() -> Results<Note>
    func writeNote(_ note: Note)
}

struct NotesRepository: RealmProtocol {
    let realm = try! Realm()
    
    
    func fetch() -> Results<Note> {
        return realm.objects(Note.self).sorted(byKeyPath: "editDate", ascending: false)
    }
    
    func fetchPinnedNotes() -> Results<Note> {
        let pinnedNotes = fetch().where {
            $0.isPinned == true
        }
        
        return pinnedNotes
    }
    
    func fetchUnpinnedNotes() -> Results<Note> {
        let unpinnedNotes = fetch().where {
            $0.isPinned == false
        }
        
        return unpinnedNotes
    }
    
    func writeNote(_ note: Note) {
        do {
            try realm.write {
                realm.add(note)
            }
        } catch {
            print(error)
        }
    }

    func updateNote(from originalNote: Note, to editedNote: Note) {
        do {
            try realm.write {
                // 하나의 레코드에서 여러 컬럼들 변경
//                self.localRealm.create(UserDiary.self, value: ["objectId": self.tasks[indexPath.row].objectId, "contents": "변경 테스트", "diaryTitle": "제목"], update: .modified)
//                self.realm.create(Note.self, value: ["objectId": note.objectId, "contents": "변경 테스트", "diaryTitle": "제목"], update: .modified)
                
                originalNote.editDate = Date()
                originalNote.title = editedNote.title
                originalNote.contents = editedNote.contents
                
//                @Persisted(primaryKey: true) var objectId: ObjectId
//                @Persisted var writeDate = Date()  // 작성일(필수)
//                @Persisted var editDate = Date()   // 수정일(필수)
//                @Persisted var title: String       // 제목(필수)
//                @Persisted var contents: String?   // 내용(추가 텍스트)(옵션)
//                @Persisted var isPinned: Bool      // 고정 여부(필수)
            }
        } catch {
            print(error)
        }
    }
    
    func updatePinned(of note: Note) {
        do {
            try realm.write {
                note.isPinned.toggle()
            }
        } catch {
            print(error)
        }
    }
}
