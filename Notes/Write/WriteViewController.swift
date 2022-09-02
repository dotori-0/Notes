//
//  WriteViewController.swift
//  Notes
//
//  Created by SC on 2022/09/02.
//

import UIKit

class WriteViewController: BaseViewController {
    let writeView = WriteView()
    
    override func loadView() {
        view = writeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func setUI() {
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareButtonClicked))
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(doneButtonClicked))
        navigationItem.rightBarButtonItems = [doneButton, shareButton]
        navigationItem.backButtonTitle = "메모"
    }
    
    @objc func shareButtonClicked() {

    }
    
    @objc func doneButtonClicked() {
        
    }
}
