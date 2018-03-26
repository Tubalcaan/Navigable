//
//  Navigable.swift
//  TestBeadGrid
//
//  Created by eliksir on 16/03/2018.
//  Copyright © 2018 eliksir. All rights reserved.
//

import Foundation
import UIKit

public enum TransitionType {
    case push
    case defaultModal
    case modal(configuration: TransitionConfiguration)
}
public struct TransitionConfiguration {
    public var transitionStyle: UIModalTransitionStyle = .coverVertical
    public var presentationStyle: UIModalPresentationStyle = .fullScreen
    public var transition: Transition? = nil
    
    /// default is coverVertical / fullScreen
    public static var `default`: TransitionConfiguration {
        return TransitionConfiguration()
    }
    
    public init(transitionStyle: UIModalTransitionStyle = .coverVertical, presentationStyle: UIModalPresentationStyle = .fullScreen, transition: Transition? = nil) {
        self.transitionStyle = transitionStyle
        self.presentationStyle = presentationStyle
        self.transition = transition
    }
}

// MARK: UIViewController
public extension UIViewController {
    public func go<T: Navigable>(to controllerType: T.Type, with params: T.Params? = nil, transitionType: TransitionType = .push, animated: Bool = true, completion: (() -> Swift.Void)? = nil) {
        Router.shared.go(to: controllerType, from: self, with: params, transitionType: transitionType, animated: animated, completion: completion)
    }
}

// MARK: Navigable
public protocol NavigationParameters {}
public protocol Navigable {
    associatedtype Params: NavigationParameters
    
    static var storyboardIdentifier: String { get }
    static var identifier: String { get }
    
    func configure(with params: Params?)
}

public extension Navigable where Self: UIViewController {
    public static var identifier: String {
        return String(describing: Self.self)
    }
    
    public static var storyboardIdentifier: String {
        return "Main"
    }
    
    public func goBack(animated: Bool = true, completion: (() -> Swift.Void)? = nil) {
        Router.shared.goBack(from: self, animated: animated, completion: completion)
    }
}


