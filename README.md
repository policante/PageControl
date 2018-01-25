# PageControl

[![Version](https://img.shields.io/cocoapods/v/PageControl.svg?style=flat)](http://cocoapods.org/pods/PageControl)
[![License](https://img.shields.io/cocoapods/l/PageControl.svg?style=flat)](http://cocoapods.org/pods/PageControl)
[![Platform](https://img.shields.io/cocoapods/p/PageControl.svg?style=flat)](http://cocoapods.org/pods/PageControl)

A simple way to navigate between pages by using gestures

![Demo image](/images/demo.gif)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* iOS 8.3 or higher

## Installation

PageControl is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PageControl'
```

## Usage

In your storyboard, add a container view of the type PageControlViewController

![example1 image](/images/example1.png)

```swift
self.pageController.delegate = self
self.pageController.dataSource = self

extension ViewController: PageControlDelegate {
  func pageControl(_ pageController: PageControlViewController, atSelected viewController: UIViewController) {
    (viewController as! CardItemViewController).animateImage()
  }

  func pageControl(_ pageController: PageControlViewController, atUnselected viewController: UIViewController) {
  }   
}

extension ViewController: PageControlDataSource {
  func numberOfCells(in pageController: PageControlViewController) -> Int {
    return self.dataController.count
  }

  func pageControl(_ pageController: PageControlViewController, cellAtRow row: Int) -> UIViewController! {
    return self.dataController[row]
  }

  func pageControl(_ pageController: PageControlViewController, sizeAtRow row: Int) -> CGSize {
    let width = pageController.view.bounds.size.width - 20
    if row == pageController.currentPosition {
      return CGSize(width: width, height: 500)
    }
    return CGSize(width: width, height: 500)
  }

}
```

If you need to change the page manually, use:

```swift

self.pageController.currentPosition = index

self.pageController.nextPage()

self.pageController.previousPage()

```


## Author

Rodrigo Martins, policante.martins@gmail.com

## License

PageControl is available under the MIT license. See the LICENSE file for more info.
