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

// MARK: XibInstantiable
public protocol XibInstantiable: class {
    static var xibIdentifier: String { get }
    static var identifier: String { get }
}
public extension XibInstantiable where Self: UIViewController {
    public static var identifier: String {
        return String(describing: Self.self)
    }
    
    public static var xibIdentifier: String {
        return "Main"
    }
}

public extension XibInstantiable where Self: UIView {
    public static var identifier: String {
        return String(describing: Self.self)
    }
    
    public static var xibIdentifier: String {
        return String(describing: Self.self)
    }
}

// MARK: MVPView
// Interactions are missing
public protocol MVPView: XibInstantiable {
    associatedtype Presenter: MVPPresenter
    
    var presenter: Presenter { get set }
}

// MARK: MVPPresenter
public protocol MVPPresenter {
    associatedtype Params
    associatedtype View: MVPView

    var view: View? { get set }
    
    func configure(with params: Params?)
}

// MARK: Navigable
public protocol NavigationParameters {}
public protocol MVPNavigable: MVPView {
}

public extension MVPNavigable where Self: UIViewController {
    public func goBack(from fromVC: UIViewController?, animated: Bool = true, completion: (() -> Swift.Void)? = nil) {
        let fromViewController = fromVC ?? self
        Router.shared.goBack(from: fromViewController, animated: animated, completion: completion)
    }
}

public protocol MVPNavigator {
}
public extension MVPNavigator {
    public static func go<T: MVPNavigable>(from fromVC: UIViewController, to controllerType: T.Type, with params: T.Presenter.Params? = nil, transitionType: TransitionType = .push, animated: Bool = true, completion: (() -> Swift.Void)? = nil) {
        Router.shared.go(from: fromVC, to: controllerType, with: params, transitionType: transitionType, animated: animated, completion: completion)
    }

    public static func go<T: MVPNavigable>(using segue: UIStoryboardSegue, to navigable: T.Type, with params: T.Presenter.Params? = nil, completion: (() -> Swift.Void)? = nil) {
        if segue.destination is T {
            Router.shared.go(from: segue.source, to: navigable, with: params, completion: completion)
        }
    }
}

// MARK: Example
class Navigator: MVPNavigator {
    func toSecondScreen(segue: UIStoryboardSegue, params: MySecondPres.Params?) {
        Navigator.go(using: segue, to: MySecondVC.self, with: params)
    }
    
    func toSecondScreen(with params: MySecondPres.Params?, from fromVC: UIViewController) {
        Navigator.go(from: fromVC, to: MySecondVC.self, with: params)
    }
}

protocol MyView: MVPView {}
class MyVC: UIViewController, MyView {
    var presenter: MyPres = MyPres()
}
protocol MyPresenter: MVPPresenter {}
class MyPres: MyPresenter {
    struct Params {
    }

    weak var view: MyVC?
    
    func configure(with params: MyPres.Params?) {
    }
}

protocol MySecondView: MVPNavigable {}
class MySecondVC: UIViewController, MySecondView {
    var presenter: MySecondPres = MySecondPres()
    
    @IBOutlet weak var label: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        label.text = presenter.value
    }
    
    func doSomething(with str: String) {
    }
    
    @IBAction func didAction(_ sender: Any) {
        presenter.didAction()
    }
}
protocol MySecondPresenter: MVPPresenter {}
class MySecondPres: MySecondPresenter {
    struct Params {
        var value: String = ""
    }
    
    weak var view: MySecondVC?
    
    var value: String = ""
    
    func configure(with params: MySecondPres.Params?) {
        value = params?.value ?? ""
    }
    
    func didAction() {
        view?.doSomething(with: value)
    }
}

