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
    func fetchPinnedNotes() -> Results<Note>
    func fetchUnpinnedNotes() -> Results<Note>
    func findNotes(with searchText: String) -> Results<Note>
    func writeNote(_ note: Note)
    func updateNote(from originalNote: Note, to editedNote: Note)
    func updatePinned(of note: Note)
    func deleteNote(_ note: Note)
    func deleteNote(id: ObjectId)
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
    
    func findNotes(with searchText: String) -> Results<Note> {
        let foundNotes = fetch().where { note in
            note.title.contains(searchText, options: .caseInsensitive) || note.contents.contains(searchText, options: .caseInsensitive)
        }
        
        return foundNotes
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
                originalNote.editDate = Date()
                originalNote.title = editedNote.title
                originalNote.contents = editedNote.contents
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
    
    func deleteNote(_ note: Note) {
        do {
            try realm.write {
                realm.delete(note)
            }
        } catch {
            print(error)
        }
    }
    
    func deleteNote(id: ObjectId) {
        let noteToBeDeleted = fetch().where {
            $0.objectId == id
        }
        
        if let note = noteToBeDeleted.first {
            deleteNote(note)
        }
    }
}
