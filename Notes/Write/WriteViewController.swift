//
//  WriteViewController.swift
//  Notes
//
//  Created by SC on 2022/09/02.
//

import UIKit

class WriteViewController: BaseViewController {
    
    // MARK: - Properties
    
    let writeView = WriteView()
    let repository = NotesRepository()
    
    var isExistingNote = false
    var note: Note?
    
    
    // MARK: - Functions
    
    override func loadView() {
        view = writeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        print("selected note: \(note)")
        if isExistingNote {
            showExistingNote()
        } else {
            writeView.textView.becomeFirstResponder()
        }
    }
    
    override func setUI() {
        super.setUI()
        navigationItem.largeTitleDisplayMode = .never
        
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareButtonClicked))
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(doneButtonClicked))
        navigationItem.rightBarButtonItems = [doneButton, shareButton]
        navigationItem.backButtonTitle = "메모"
    }
    
    func showExistingNote() {
        writeView.textView.text = note?.title
        
        if let contents = note?.contents {
            writeView.textView.text += contents
        }
//        writeView.textView.text += note?.contents
    }
    
    @objc func shareButtonClicked() {
        
    }
    
    @objc func doneButtonClicked() {
        if isExistingNote {
            checkChangesAndUpdateNoteToRealm()
        } else {
            saveNoteToRealm()
        }
        
        writeView.endEditing(true)
//        navigationController?.popViewController(animated: true)
    }
    
    func saveNoteToRealm() {
        guard let text = writeView.textView.text else {
            print("Cannot find text in Text View")
            return
        }
        
        let titleAndContentsArray = writeView.textView.text.components(separatedBy: .newlines)
//        print(titleAndContentsArray)
        guard let title = titleAndContentsArray.first else {
            print("Cannot find title")
            return
        }

//        print("title: \(title)")
        print("text.hasPrefix(title): \(text.hasPrefix(title))")
        
        let contentsSubsequence = text.dropFirst(title.count)  // Type: String.SubSequence
        let contents = String(contentsSubsequence)             // Non-optional

//        guard let contents = String(contentsSubsequence) else {
//            print("Cannot change contentsSubsequence to String")
//            return
//        }
//        print(contents)
//        print(type(of: contentsSubsequence))
//        print(type(of: contents))
        
        let note = Note(title: title, contents: contents)
        print(note)
        repository.writeNote(note)
    }
    
    func checkChangesAndUpdateNoteToRealm() {
        guard let text = writeView.textView.text else {
            print("Cannot find text in Text View")
            return
        }
        
        let titleAndContentsArray = writeView.textView.text.components(separatedBy: .newlines)
        
        guard let title = titleAndContentsArray.first else {
            print("Cannot find title")
            return
        }

        print("text.hasPrefix(title): \(text.hasPrefix(title))")
        
        let contentsSubsequence = text.dropFirst(title.count)  // Type: String.SubSequence
        let contents = String(contentsSubsequence)             // Non-optional
        
        let editedNote = Note(title: title, contents: contents)
        print(editedNote)
        
        guard let originalNote = note else { return }
        
        if originalNote.title != editedNote.title || originalNote.contents != editedNote.contents  {
            repository.updateNote(from: originalNote, to: editedNote)
        }
    }
}
