//
//  Alert+Extension.swift
//  Notes
//
//  Created by SC on 2022/09/04.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, style: UIAlertAction.Style = .default, allowsCancel: Bool = false, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: style, handler: handler)
        alert.addAction(ok)
        
        if allowsCancel {
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            alert.addAction(cancel)
        }
        
        present(alert, animated: true)
    }
}


