//
//  NotesRepository.swift
//  Notes
//
//  Created by SC on 2022/09/02.
//

import Foundation
import RealmSwift

protocol RealmProtocol {
    func writeNote(_ note: Note)
    func fetch() -> Results<Note>
}

struct NotesRepository: RealmProtocol {
    let realm = try! Realm()
    
    func writeNote(_ note: Note) {
        do {
            try realm.write {
                realm.add(note)
            }
        } catch {
            print(error)
        }
    }
    
    func fetch() -> Results<Note> {
        return realm.objects(Note.self).sorted(byKeyPath: "editDate")
    }
}
