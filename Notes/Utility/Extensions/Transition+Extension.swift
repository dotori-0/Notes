//
//  Transition+Extension.swift
//  Notes
//
//  Created by SC on 2022/09/02.
//

import UIKit

extension UIViewController {
    enum TransitionStyle {
        case push
    }
    
    func transition<T: UIViewController>(to vc: T, transitionStyle: TransitionStyle = .push) {
        switch transitionStyle {
            case .push:
                self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
