# SwiftyStoryboard

[![Build Status](https://travis-ci.org/gavrix/SwiftyStoryboard.svg?branch=master)](https://travis-ci.org/gavrix/SwiftyStoryboard) 

A set of runtime hacks and extensions to make cocoa storyboards more accessible from swift environment. 

## Usage

### Statically typed segue identifiers

This a UIViewController extension to turn string based segue identifiers into enum cases.
Conform your ViewController to `StaticTypeSegueIdentifierSupport` protocol and define internal enum type with name `SegueIdentifier`:

```swift

class SampleViewController: UIViewController, StaticTypeSegueIdentifierSupport {
    enum SegueIdentifier: String {
        case Segue1
        case Segue2
    }
}
```

Enum cases should match by name those segue identifiers defined for the viewController your storyboard. Next, you'd be able to perform segue by giving enum type as a segue identifier (rather than a raw string):

```swift

let vc: SampleViewController
vc.performSegue(SampleViewController.SegueIdentifier.Segue1)

```

You can find more in [NatashaTheRobot's](https://twitter.com/natashatherobot) original blog [post](https://www.natashatherobot.com/protocol-oriented-segue-identifiers-swift/)

### Statically typed ViewController's configuration

This UIViewController extension allows you to inject destination ViewController's configuration function at the time of performing a segue.

You need to make your ViewController conform to `StaticTypeSegueSupport` and you will automatically have the following method appeared:

```swift
func performSegue<U: UIViewController>(segueIdentifier: String, configure: (U)->())
```

It takes the segueIdentifier as well as the function used inside `prepapreForSegue:` to configure destination ViewController. The method is generic parameterized with the type of destination ViewController, which means you don't have to do additional cast.

```swift
class SampleViewController: StaticTypeSegueSupport {

...
	try self.performSegue("segueIdentifier") { (destinationVC:DestinationViewController) in
	   destinationVC.modelData = modelData
	}
...		
}
```

You can combine it with `StaticTypeSegueIdentifierSupport` and have additional statically typed segue identifiers support too:

```swift
class SampleViewController: StaticTypeSegueSupport, StaticTypeSegueIdentifierSupport {
	enum SegueIdentifier: String {
        case Segue1
        case Segue2
    }
...
	try self.performSegue(.Segue1) { (destinationVC:DestinationViewController) in
	   destinationVC.modelData = modelData
	}
...		
}
```

## Error handling

Because of dynamic storyboard nature, some information is only possible to be checked at runtime. `SwiftyStoryboard` attempts to catch any runtime exception and translate it into native `ErrorType` compatible error so it could be caught by swift's native error handling.

There are two supported errors at the moment: 

- `RuntimeSegueIdentifierError` thrown by `performSegue(segue: SegueIdentifier) throws` when segue identifier not found in the storyboard
- `RuntimeTypeMismatchError` thrown by `performSegue<U: UIViewController>(segueIdentifier: String, configure: (U)->())` when actual destination ViewController's type and the one expected by `configure` don't match.


## Credits

`SwiftyStoryboard` created by Sergey Gavrilyuk [@octogavrix](https://twitter.com/octogavrix).
Statically typed segue identifiers idea and implementation by [@NatashaTheRobot](https://twitter.com/natashatherobot). 

## License

`SwiftyStoryboard` is distributed under MIT license. See LICENSE for more info.
