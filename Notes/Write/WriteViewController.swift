//
//  WriteViewController.swift
//  Notes
//
//  Created by SC on 2022/09/02.
//

import UIKit

final class WriteViewController: BaseViewController {
    // MARK: - Properties
    
    private let writeView = WriteView()
    private let repository = NotesRepository()
    
    var isFromSearch = false
    var isExistingNote = false
    private var deletedNote = false
    var note: Note?
    
    private var barButtons: [UIBarButtonItem] = []
    
    
    // MARK: - Functions
    
    override func loadView() {
        view = writeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        writeView.textView.delegate = self

        if isExistingNote {
            showExistingNote()
        } else {
            writeView.textView.becomeFirstResponder()
        }
        
        hideAndShowDoneButton(isEditing: !isExistingNote)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print(#function)
        
        if !deletedNote {
            updateOrSaveNoteToRealm()
        }
    }
    
    override func setUI() {
        super.setUI()
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.topItem?.title = isFromSearch ? Notice.search : Notice.notes
    }
    
    private func hideAndShowDoneButton(isEditing: Bool) {
        let shareButton = UIBarButtonItem(image: UIImage(systemName: SymbolName.share), style: .plain, target: self, action: #selector(shareButtonClicked))
        barButtons = [shareButton]
        
        if isEditing {
            let doneButton = UIBarButtonItem(title: Notice.done, style: .done, target: self, action: #selector(doneButtonClicked))
            barButtons.insert(doneButton, at: 0)
        }

        navigationItem.rightBarButtonItems = barButtons
    }
    
    private func showExistingNote() {
        writeView.textView.text = note?.title
        
        if let contents = note?.contents {
            writeView.textView.text += contents
        }
    }
    
    @objc private func shareButtonClicked() {
        showActivityViewController()
    }
    
    private func showActivityViewController() {
        let vc = UIActivityViewController(activityItems: [writeView.textView.text], applicationActivities: [])
        present(vc, animated: true)
    }
    
    @objc private func doneButtonClicked() {
        updateOrSaveNoteToRealm()
        isExistingNote = true
        writeView.endEditing(true)
    }
    
    private func updateOrSaveNoteToRealm() {
        if isExistingNote {
            checkChangesAndUpdateNoteToRealm()
        } else {
            saveNoteToRealm()
        }
    }
    
    private func setNote() -> Note? {
        guard let text = writeView.textView.text else {
            print("Cannot find text in Text View")
            return nil
        }
        
        // 리턴키를 기준으로 텍스트 분리
        let writtenTextsArraySeparatedByNewLines = writeView.textView.text.components(separatedBy: .newlines)

        // 분리된 배열의 첫 번째 요소
        guard let firstElementOfWrittenTextsArraySeparatedByNewLines = writtenTextsArraySeparatedByNewLines.first else {
            print("Cannot find the first element of writtenTextsArraySeparatedByNewLines")
            return nil
        }
        
        // 타이틀에도 스페이스 하나 조차 없이 아예 비어 있다면 저장하지 않도록
        if writtenTextsArraySeparatedByNewLines.count == 1 && firstElementOfWrittenTextsArraySeparatedByNewLines.isEmpty {
            return nil
        }
        
        // 실제로 작성하는 텍스트와 그 후의 리턴 키를 기준으로 타이틀을 분리
        var realTextsArray: [String] = []
        
        for text in writtenTextsArraySeparatedByNewLines {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedText.isEmpty {
                realTextsArray.append(trimmedText)
            }
        }
        
        // 실제 텍스트가 아예 없을 시 저장되지 않도록
        guard let firstActualText = realTextsArray.first else {
            print("No actual texts at all")
            return nil
        }
        
        let writtenTextsArraySeparatedByFirstRealText = writeView.textView.text.components(separatedBy: firstActualText)
        
        guard let whiteSpacesAndNewLinesBeforeTheFirstRealText = writtenTextsArraySeparatedByFirstRealText.first else {
            print("Cannot find whiteSpacesAndNewLinesBeforeTheFirstRealText")
            return nil
        }
        
        let title = "\(whiteSpacesAndNewLinesBeforeTheFirstRealText)\(firstActualText)"
        
        let contentsSubsequence = text.dropFirst(title.count)  // Type: String.SubSequence
        let contents = String(contentsSubsequence)             // Non-optional
        
        let note = Note(title: title, contents: contents)
        
        return note
    }
    
    private func saveNoteToRealm() {
        guard let note = setNote() else { return }
        repository.writeNote(note)
        self.note = note
    }
    
    private func checkChangesAndUpdateNoteToRealm() {
        guard let editedNote = setNote() else {
            if let originalNote = note {
                repository.deleteNote(id: originalNote.objectId)
                deletedNote = true
                print("Successfully Deleted")
            }
            return
        }
        
        guard let originalNote = note else { return }
        
        if originalNote.title != editedNote.title || originalNote.contents != editedNote.contents  {
            repository.updateNote(from: originalNote, to: editedNote)
        }
    }
}


extension WriteViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        hideAndShowDoneButton(isEditing: true)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        hideAndShowDoneButton(isEditing: false)
    }
}
