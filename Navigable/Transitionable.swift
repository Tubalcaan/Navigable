//
//  Transitionable.swift
//  Navigable
//
//  Created by eliksir on 26/03/2018.
//  Copyright © 2018 eliksir. All rights reserved.
//

import Foundation
import UIKit

public protocol Transition: UIViewControllerAnimatedTransitioning {
    func willShow()
    func willDismiss()
}

