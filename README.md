<h3 align="center"><img src="navigable_logo.png" width=120></h3>
<br>

[![Carthage compatible](https://img.shields.io/badge/Cocoapods-compatible-green.svg?style=flat)](https://github.com/Carthage/Carthage)
 [![Cocoapods compatible](https://img.shields.io/badge/Cocoapods-compatible-orange.svg?style=flat)](https://github.com/CocoaPods/CocoaPods)

# Navigable
Navigable is a light framework aimed to **simplify the navigation** between UIViewControllers and the configuration of these UIViewControllers when the user gets from one to another one.

### Segues are cool but... 🤔
Segues are **very good tools** to represent visual connections between View controllers. But they have few drawbacks:
* Segue names are **Strings**. Crashes may occur when using a Segue which name is not well configured in the storyboard
* In huge apps, many screens can be accessed different ways and from multiple view controllers. Each connection is a new Segue in storyboards. This may cause the **octopus effect 🐙**, with eye-unreadable links between screens
* Listing all ins and outs of a specific view controller may be a very difficult task to achieve, as many different Segue names may go to the same view controller
* Sending parameters to the destination UIViewController usually needs to implement prepareForSegue:sender: and switch between all the different segues. Transitioning to a view controller **requires code in multiple places** (performSegue(withIdentifier:sender:) and prepareForSegue:sender:)

### UIViewController programmatic instantiation is cool but... 🤔
Any time you want to push or present a view controller, you have to repeat a few lines of code (that I personnaly never remember). Every time you do this, you have to **check the storyboard name and storyboard ID** of the UIViewController.
The code is a bit different, and it's hard to search in XCode.

# Using Navigable
### Compatibility
* Navigable works on platform 9.0+
* This version is Swift4 compatible

### Context
* Your app contains 2 UIViewControllers: FirstViewController and SecondViewController
* FirstViewController contains a button, that leads to SecondViewController. SecondViewController displays the number of taps on the button
* FirstViewController is the delegate of SecondViewController

### Implementation
Add an extension to SecondViewController that implements the Navigable protocol. Navigable defines the input parameters of the destination view controller and a configure(with:) function to call before pushing the controller.

⚠️ In the basic use case, the storyboard ID of the UIViewController must be equal to its class name and the storyboard is considered to be the Main.storyboard. If your use case is different, read further

```Swift
extension SecondViewController: Navigable {
    struct Params: NavigationParameters {
        var numberOfTaps: Int = 0
        var delegate: SecondViewControllerDelegate? = nil
    }

    func configure(with params: SecondViewController.Params) {
        self.numberOfTaps = params.numberOfTaps
        self.delegate = params.delegate
    }
}
```

### ➡️ Push
To push SecondViewController, call the go(to:with:) function
```Swift
@IBAction func buttonTapped(_ sender: Any) {
  numberOfTaps += 1 // count the number of taps
  go(to: SecondViewController.self, with: SecondViewController.Params(numberOfTaps: numberOfTaps, delegate: self))
}
```

### ⬆️ Modal
To present SecondViewController modally:
```Swift
@IBAction func buttonTapped(_ sender: Any) {
  numberOfTaps += 1 // count the number of taps
  go(to: SecondViewController.self, with: SecondViewController.Params(numberOfTaps: numberOfTaps, delegate: self), presentationType: PresentationType.defaultModal) // presents coverVertical/fullScreen
}
```

### ⬅️ Pop/Dismiss
Whatever the way you displayed SecondViewController (push/present), going back to FirstViewController is coded the same way
```Swift
goBack()
```

# 👍 Benefits
* Only one function to push/present a UIViewController
* Only one function to get back to previous UIViewController
* Input parameters definition is placed in the corresponding UIViewController
* Injection of wrong parameters type is a compilation error. You cannot miss a parameter or send the wrong one
* Searching ins and outs of a specific UIViewController is easily made by searching "go(to:)" in the project

# What more ?
#### My UIViewController has a custom storyboard ID
Add a static read-only variable named "identifier" to the UIViewController (in the Navigable extension is more readable)
```Swift
extension SecondViewController: Navigable {
  static var identifier: String {
    return "MyCustomIdentifier" // as declared in the storyboard, may be a constant
  }
}
```

#### My UIViewController is not in the Main.storyboard
The framework considers that the UIViewControllers are in the "Main" storyboard. If your controller is in another storyboard (which looks like a good idea if your app has lots of features), just specify the name of the storyboard as a static read-only variable (named "storyboardIdentifier")
```Swift
extension SecondViewController: Navigable {
  static var storyboardIdentifier: String {
    return "MyOtherStoryboardName" // the exact name of the storyboard, may be a constant
  }
}
```

#### I want to customize the transition
The go(to:) has more parameters with default values.
* animated: determines if the transition is animated
* completion: determines the block that will be called after the transition

The framework provides a PresentationConfiguration enum that enables you to specify the UIModalTransitionStyle and UIModalPresentationStyle for modal transitions.
Just pass the custom PresentationConfiguration to the go(to:) function.

# Installation
## Carthage
To install, simply add the following lines to your Cartfile :
```ruby
github "Tubalcaan/Navigable" ~> 1.0
```
## Cocoapods
To install, simply add the following lines to your Podfile :
```ruby
pod 'Navigable', :git => 'https://github.com/Tubalcaan/Navigable.git', :branch => 'master'
```
