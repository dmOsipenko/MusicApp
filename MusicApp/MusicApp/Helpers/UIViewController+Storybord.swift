//
//  UIViewController+Storybord.swift
//  MusicApp
//
//  Created by Дмитрий Осипенко on 29.08.21.
//

import UIKit

extension UIViewController {
    class func LoadFromStorybord<T: UIViewController>() -> T {
        let name = String(describing: T.self)
        let storybord = UIStoryboard(name: name, bundle: nil)
        if let viewController = storybord.instantiateInitialViewController() as? T {
            return viewController
        }else {
            fatalError("No initial ViewController \(name) storybord")
        }
    }
}
