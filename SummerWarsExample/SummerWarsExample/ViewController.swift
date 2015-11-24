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
	let bundle = NSBundle(forClass: SummerWarsViewController.self)

	override func viewDidLoad() {
		super.viewDidLoad()
		
		var contents = [WarsContent]()
		
		for _ in 0..<30{
        	let image = UIImage(named: "SummerWars.bundle/images/image\(Int.random(max: 17)).jpg", inBundle: bundle, compatibleWithTraitCollection: nil) ?? UIImage()
			contents.append(WarsContent(image:image, caption: ""))
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