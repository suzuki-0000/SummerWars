SummerWars
========================

[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/SummerWars.svg?style=flat)](http://cocoadocs.org/docsets/SummerWars)
[![Swift 2.0](https://img.shields.io/badge/Swift-2.0-orange.svg?style=flat)](https://developer.apple.com/swift/)

Summerwars is the view inspired by [Summerwars](https://youtu.be/zFBrz3u8VkY?t=10s).

## features
- can display like summerwars!!

![sample](Screenshots/example01.gif)


## What is Summerwars??
- Summer Wars is a 2009 Japanese animated science fiction film. [wikipedia](https://en.wikipedia.org/wiki/Summer_Wars).
- Also See this official [video](https://youtu.be/zFBrz3u8VkY?t=10s)

##Installation

####CocoaPods
available on CocoaPods. Just add the following to your project Podfile:
```
pod 'SummerWars'
use_frameworks!
```

####Carthage
To integrate into your Xcode project using Carthage, specify it in your Cartfile:

```ogdl
github "suzuki-0000/SummerWars"
```

##Usage
example project would be easy to understand.
	
```swift
var contents = [WarsContent]()
// add some contents

let summerWarsView = SummerWarsViewController(contents: contents)
addChildViewController(summerWarsView, toContainerView: view)
```

##Options
you can customize with some options

#### one's max radius
```ogdl
public static var warsMaxRadius:CGFloat 
```

#### one's min radius
```ogdl
public static var warsMinRadius:CGFloat
```

#### central space 
```ogdl
public static var warsCentralRadius:CGFloat 
```

## License
available under the MIT license. See the LICENSE file for more info.

