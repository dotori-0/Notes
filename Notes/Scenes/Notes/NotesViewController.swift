//
//  NotesViewController.swift
//  Notes
//
//  Created by SC on 2022/09/01.
//

import UIKit

class NotesViewController: BaseViewController {
    
    // MARK: - Properties
    
    let notesView = NotesView()
    
    
    // MARK: - Functions
    
    override func loadView() {
        view = notesView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }


    override func setUI() {
        print(#function)
        
        title = "1234개의 메모"
        
        guard navigationController != nil else {
            print("no navigation controller")
            return
        }
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = notesView.searchController
        
    }
    
    override func setConstraints() {
        
    }

}
