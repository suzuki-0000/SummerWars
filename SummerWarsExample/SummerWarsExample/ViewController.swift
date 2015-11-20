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

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let summerWarsView = SummerWarsView()
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
