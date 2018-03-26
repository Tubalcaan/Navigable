//
//  Router.swift
//  navigable
//
//  Created by eliksir on 24/03/2018.
//  Copyright © 2018 eliksir. All rights reserved.
//

import Foundation
import UIKit

class Router: NSObject {
    struct ControllerPresentation {
        weak var controller: UIViewController?
        var transitionType: TransitionType = .push
        var transition: Transition? = nil
    }
    
    static let shared = Router()
    
    private var controllers: [ControllerPresentation] = []
    
    func controllerPresentation(for vc: UIViewController) -> ControllerPresentation? {
        if let index = controllers.index(where: { controllerPresentation -> Bool in
            return controllerPresentation.controller === vc
        }) {
            return controllers[index]
        }
        
        return nil
    }
    
    func go<T: Navigable>(to type: T.Type, from originVC: UIViewController, with params: T.Params?, transitionType: TransitionType = .push, animated: Bool = true, completion: (() -> Swift.Void)? = nil) {
        let storyBoard = getStoryboard(T.storyboardIdentifier)
        if let navigable = storyBoard.instantiateViewController(withIdentifier: T.identifier) as? T {
            navigable.configure(with: params)
            if let nextViewController = navigable as? UIViewController {
                displayController(nextViewController, from: originVC, transitionType: transitionType, animated: animated, completion: completion)
            }
        }
    }
    
    func goBack(from originController: UIViewController, animated: Bool = true, completion: (() -> Swift.Void)? = nil) {
        if let index = controllers.index(where: { controllerPresentation -> Bool in
            return controllerPresentation.controller === originController
                || (originController.navigationController != nil && controllerPresentation.controller === originController.navigationController)
        }) {
            switch controllers[index].transitionType {
            case .push:
                if let navigationController = originController.navigationController {
                    navigationController.popViewController(animated: animated)
                }
                controllers.remove(at: index)
            case .defaultModal:
                originController.dismiss(animated: animated, completion: nil)
                controllers.remove(at: index)
            case .modal(_):
                originController.dismiss(animated: animated, completion: nil)
                controllers.remove(at: index)
            }
        }
    }
    
    func displayController(_ nextViewController: UIViewController, from originVC: UIViewController, transitionType: TransitionType = .push, animated: Bool = true, completion: (() -> Swift.Void)? = nil) {
        switch transitionType {
        case .push:
            controllers.append(ControllerPresentation(controller: nextViewController, transitionType: transitionType, transition: nil))
            originVC.navigationController?.pushViewController(nextViewController, animated: animated)
        case .defaultModal:
            let navController = UINavigationController(rootViewController: nextViewController)
            navController.modalPresentationStyle = TransitionConfiguration.default.presentationStyle
            navController.modalTransitionStyle = TransitionConfiguration.default.transitionStyle
            controllers.append(ControllerPresentation(controller: nextViewController, transitionType: transitionType, transition: nil))
            originVC.present(navController, animated: animated, completion: completion)
        case .modal(let config):
            let navController = UINavigationController(rootViewController: nextViewController)
            navController.modalPresentationStyle = config.presentationStyle
            navController.modalTransitionStyle = config.transitionStyle
            navController.transitioningDelegate = self
            controllers.append(ControllerPresentation(controller: navController, transitionType: transitionType, transition: config.transition))
            originVC.present(navController, animated: animated, completion: completion)
        }
    }
    
    private func getStoryboard(_ identifier: String) -> UIStoryboard {
        return UIStoryboard(name: identifier, bundle:nil)
    }
}

extension Router: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        Router.shared.controllerPresentation(for: presented)?.transition?.willShow()
        return Router.shared.controllerPresentation(for: presented)?.transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        Router.shared.controllerPresentation(for: dismissed)?.transition?.willDismiss()
        return Router.shared.controllerPresentation(for: dismissed)?.transition
    }
}



