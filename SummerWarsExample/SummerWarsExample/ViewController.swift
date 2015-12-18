//
//  ViewController.swift
//  SummerWarsExample
//
//  Created by suzuki keishi on 2015/11/10.
//  Copyright © 2015年 suzuki_keishi. All rights reserved.
//

import UIKit
import SummerWars

class ViewController: UIViewController {
	var captions = ["Lorem Ipsum.",
		"it to make a type specimen book.",
		"It has survived not typesetting",
		"remaining of Lorem Ipsum.",
		"simply dummy text of the printing and typesetting industry.",
		"text ever since the 1500s"
	]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		var contents = [WarsContent]()
		
		for _ in 0..<30{
        	let image = UIImage(named: "image\(Int.random(max: 16)).jpg") ?? UIImage()
			contents.append(WarsContent(image:image, caption: captions[Int.random(max: captions.count - 1)]))
		}
		
		let summerWarsView = SummerWarsViewController(contents: contents)
		addChildViewController(summerWarsView, toContainerView: view)
	}
}

extension UIViewController {
	func addChildViewController(vc: UIViewController, toContainerView containerView: UIView) {
		addChildViewController(vc)
		containerView.addSubview(vc.view)
		vc.didMoveToParentViewController(self)
	}
}

extension Int {
	static func random(min: Int = 0, max: Int) -> Int {
		return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
	}
}