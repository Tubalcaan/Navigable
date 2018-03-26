//
//  Router.swift
//  navigable
//
//  Created by eliksir on 24/03/2018.
//  Copyright © 2018 eliksir. All rights reserved.
//

import Foundation
import UIKit

class Router {
    private struct ControllerPresentation {
        weak var controller: UIViewController?
        var presentationType: PresentationType = .push
    }
    
    static let shared = Router()
    
    private var controllers: [ControllerPresentation] = []
    
    func go<T: Navigable>(to type: T.Type, from originVC: UIViewController, with params: T.Params, presentationType: PresentationType = .push, animated: Bool = true, completion: (() -> Swift.Void)? = nil) {
        let storyBoard = getStoryboard(T.storyboardIdentifier)
        if let navigable = storyBoard.instantiateViewController(withIdentifier: T.identifier) as? T {
            navigable.configure(with: params)
            if let nextViewController = navigable as? UIViewController {
                displayController(nextViewController, from: originVC, presentationType: presentationType, animated: animated, completion: completion)
                controllers.append(ControllerPresentation(controller: nextViewController, presentationType: presentationType))
            }
        }
    }
    
    func goBack(from originController: UIViewController, animated: Bool = true, completion: (() -> Swift.Void)? = nil) {
        if let index = controllers.index(where: { controllerPresentation -> Bool in
            return controllerPresentation.controller === originController
        }) {
            switch controllers[index].presentationType {
            case .push:
                controllers.remove(at: index)
                if let navigationController = originController.navigationController {
                    navigationController.popViewController(animated: animated)
                }
            case .defaultModal:
                controllers.remove(at: index)
                originController.dismiss(animated: animated, completion: nil)
            case .modal(_):
                controllers.remove(at: index)
                originController.dismiss(animated: animated, completion: nil)
            }
        }
    }
    
    func displayController(_ nextViewController: UIViewController, from originVC: UIViewController, presentationType: PresentationType = .push, animated: Bool = true, completion: (() -> Swift.Void)? = nil) {
        switch presentationType {
        case .push:
            originVC.navigationController?.pushViewController(nextViewController, animated: animated)
        case .defaultModal:
            let navController = UINavigationController(rootViewController: nextViewController)
            navController.modalPresentationStyle = PresentationConfiguration.default.presentationStyle
            navController.modalTransitionStyle = PresentationConfiguration.default.transitionStyle
            originVC.present(navController, animated: animated, completion: completion)
        case .modal(let config):
            let navController = UINavigationController(rootViewController: nextViewController)
            navController.modalPresentationStyle = config.presentationStyle
            navController.modalTransitionStyle = config.transitionStyle
            originVC.present(navController, animated: animated, completion: completion)
        }
    }
    
    private func getStoryboard(_ identifier: String) -> UIStoryboard {
        return UIStoryboard(name: identifier, bundle:nil)
    }
}
