SummerWars
========================

[![Swift 2.0](https://img.shields.io/badge/Swift-2.0-orange.svg?style=flat)](https://developer.apple.com/swift/)

Summerwars is the view inspired by [Summerwars](https://www.youtube.com/watch?v=zFBrz3u8VkY).

## features
- can display like summerwars
- I don't think someone want to use it
- But happy if this code make someone's help
- happy to know if some violation's there.

![sample](Screenshots/example01.gif)

## Requirements
- iOS 8.0+
- Swift 2.0+
- ARC

##Installation
- TODO

##Usage
example project would be easy to understand.
	
```swift
var contents = [WarsContent]()

for _ in 0..<30{
let image = UIImage(named: "image\(Int.random(max: 17)).jpg") ?? UIImage()
        contents.append(WarsContent(image:image, caption: captions[Int.random(max: captions.count - 1)]))
}

let summerWarsView = SummerWarsViewController(contents: contents)
addChildViewController(summerWarsView, toContainerView: view)
```

## License
available under the MIT license. See the LICENSE file for more info.

