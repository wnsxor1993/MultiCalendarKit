# MultiCalendarKit

[![Swift](https://img.shields.io/badge/swift-v5.7.2-orange?logo=swift)](https://developer.apple.com/kr/swift/)
[![Xcode](https://img.shields.io/badge/xcode-v14.2-blue?logo=xcode)](https://developer.apple.com/kr/xcode/)
[![RxSwift](https://img.shields.io/badge/RxSwift-6.5.0-red)]()
[![SnapKit](https://img.shields.io/badge/SnapKit-5.6.0-red)]()

📅 **Multiple Calendar for user variable service.**


## Installation

MultiCalendarKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MultiCalendarKit'
```

## Requirements
To use this framework, you need to extension RxSwift

```swift
import RxSwift

extension RxSwift.Reactive where Base: UIViewController {
    
    public var viewWillAppear: Observable<Bool> {
        return methodInvoked(#selector(UIViewController.viewWillAppear))
            .map { $0.first as? Bool ?? false }
    }
    
    public var viewWillDisappear: Observable<Bool> {
        return methodInvoked(#selector(UIViewController.viewWillDisappear))
            .map { $0.first as? Bool ?? false }
    }
}
```

The calendar view provided by framework is bind to the lifecycle of the ViewController using it, so requiring the mentioned elements.

## How to use

First, create a manager object for the desired calendar type, and then pass the required argument values to the initializer of the calendar controller. 
This will create the necessary components to control the calendar.

```swift
private let cellManager: MultiSelectCellManager = .init()
private lazy var cfController: CFController = .init(with: .multiSelectType(self.cellManager), viewWillAppear: self.rx.viewWillAppear.asDriver(onErrorJustReturn: false), viewWillDisappear: self.rx.viewWillDisappear.asDriver(onErrorJustReturn: false))
```


Then, add the calendar view present in the created controller to the desired ViewController where you want to display it.

```swift
self.view.addSubview(cfController.calendarView)

cfController.calendarView.snp.makeConstraints { make in
    make.leading.trailing.equalToSuperview()
    make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
    make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
}
```

Finally, bind the desired actions to the Relay present in the used manager.

```swift
self.cellManager.tappedStartDateRelay
self.cellManager.tappedEndDateRelay
```


## Author

Puco, https://wnsxor1993@github.com

## License

MultiCalendarKit is available under the ![Swift](https://img.shields.io/badge/MIT-red?logo=MIT) license. See the LICENSE file for more info.
