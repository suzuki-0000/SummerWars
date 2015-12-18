//
//  SummerWars.swift
//  SummerWars
//
//  Created by suzuki_keishi on 2015/11/10.
//  Copyright © 2015年 suzuki_keishi. All rights reserved.
//

import UIKit

public struct SummerwarsOptions{
    public static var maxLayerCount = 3 // 3 is property size for iOS.
    public static var warsMaxRadius:CGFloat = UIScreen.mainScreen().bounds.size.width * 0.3
    public static var warsMinRadius:CGFloat = UIScreen.mainScreen().bounds.size.width * 0.3 * 0.6
    public static var warsCentralRadius:CGFloat = UIScreen.mainScreen().bounds.size.width * 0.3 * 0.3 // 0.3 is property size using with eyes for iOS.
}

public class SummerWarsViewController: UIViewController, UIScrollViewDelegate {
	
	
	var summerwarsScrollView: SummerwarsScrollView!
	var summerwarsOprationView: UIView = UIView() // initialized in first.
	var summerwarsViews = [WarsView]()
	var warsContents = [WarsContent]()
	
	private var isDraggingSpace = false
	private var viewCount: Int { return warsContents.count }
	
	public required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	public convenience init() {
		self.init(nibName: nil, bundle: nil)
	}
	
	public convenience init(contents:[WarsContent]) {
		self.init(nibName: nil, bundle: nil)
		self.warsContents = contents
	}
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nil, bundle: nil)
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		// call home view first.
		createSummerwars()
		showSummerwars()
	}
	
	public override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(true)
	}
	
	private func createSummerwars() {
		// create scrollview
		summerwarsScrollView = SummerwarsScrollView(frame: CGRectMake(0, 0, view.frame.width, view.frame.height))
		summerwarsScrollView.delegate = self
		summerwarsScrollView.maximumZoomScale = 1.2
		summerwarsScrollView.minimumZoomScale = 0.5
		summerwarsScrollView.showsHorizontalScrollIndicator = false
		summerwarsScrollView.showsVerticalScrollIndicator = false
		summerwarsScrollView.pagingEnabled = false
		summerwarsScrollView.directionalLockEnabled = false
		summerwarsScrollView.backgroundColor = .clearColor()
		
		view.addSubview(summerwarsScrollView)
		
		// create home space.
		createHomeSpace()
	}
	
	func createHomeSpace() {
		
		// create virtual view dynamically
		let layerCount = getLayerCountByCount(viewCount)
		let lastLayerRadius = getLayerRadius(layerCount + 1) // + 1 is for space for outer
		
		// calcrate dynamic space size. (diameter of mexlayer) + outer white space
		var virtualSpaceSize = (lastLayerRadius * 2.0) + view.frame.width/2
		// if dynamic view size is smaller than device height, make scale up for scrolling
		if virtualSpaceSize < summerwarsScrollView.frame.height * 2.0 {
			virtualSpaceSize = summerwarsScrollView.frame.height * 2.0
		}
		let centerVirtualSpace = CGPointMake(virtualSpaceSize/2.0, virtualSpaceSize/2.0)
		
		// calcurate center point of scroll view
		let upLeftX = virtualSpaceSize/2 - summerwarsScrollView.frame.width/2
		let upLeftY = virtualSpaceSize/2 - summerwarsScrollView.frame.height/2
		
		summerwarsOprationView = UIView(frame: CGRectMake(0, 0, virtualSpaceSize, virtualSpaceSize))
		summerwarsOprationView.transform = CGAffineTransformMakeScale(0.0, 0.0)
		summerwarsOprationView.alpha = 0.1
		
		summerwarsScrollView.contentSize = summerwarsOprationView.bounds.size
		summerwarsScrollView.setContentOffset(CGPointMake(upLeftX, upLeftY), animated: false)
		summerwarsScrollView.addSubview(summerwarsOprationView)
		
		var warCountIndex = 0
		// 1. loop layercount which is calcurated by event.count, request from server ( eg. 1.2.3.. 15 )
		// 2. loop layerLimitCount for each layer whici is calculated by layer. (eg. 3, 7, 14..)
		for layerIndex in 0...layerCount {
			// get war count for each layer
			let currentLayerOfMaxWarCount = getMaxCountOfLayer(layerIndex)
			let currentLayerRadius = getLayerRadius(layerIndex)
			
			var layerLimitCount:Int!
			if layerIndex == layerCount{
				// count war if it is last layer
				layerLimitCount = viewCount - warCountIndex
			} else {
				// not the end of layer, apply max war count
				layerLimitCount = currentLayerOfMaxWarCount
			}
			
			// 2π / layerLimitCount = theta.
			let theta = 2.0 * M_PI / Double(layerLimitCount)
			// this is for random views
			let diffTheta: Double = Double( rand() / 10 ) / 10.0
			
			for warsPoint in 0..<layerLimitCount {
				
				// pin [x/y] center point from cos(theta * hypotenuse of event point), sin(theta * hypotenuse)
				let centerX = centerVirtualSpace.x + currentLayerRadius * CGFloat(cos(diffTheta + theta * Double(warsPoint)))
				let centerY = centerVirtualSpace.y + currentLayerRadius * CGFloat(sin(diffTheta + theta * Double(warsPoint)))
				
				let r = getLayerRadiusBySize(Int.random(max: getMaxWarSizeOfMaxCircleRadius()))
				let summerwarsView = WarsView()
				summerwarsView.frame = CGRectMake(0.0, 0.0, r*2.0, r*2.0)
				summerwarsView.center = CGPointMake(centerX, centerY)
				
				// image
				if warsContents.count > 0 {
					let image = warsContents[warCountIndex]
    				summerwarsView.setWar(image)
				}
				
				// add to local cache
				summerwarsViews.append(summerwarsView)
				
				// add to view
				summerwarsOprationView.addSubview(summerwarsView)
				
				warCountIndex++
			}
		}
		
		// this is what we can see like a 3D view
		for index in 0..<summerwarsViews.count {
			if(index % 3 == 1){ summerwarsOprationView.bringSubviewToFront(summerwarsViews[index]) }
		}
		for index in 0..<summerwarsViews.count {
			if(index % 3 == 2){ summerwarsOprationView.bringSubviewToFront(summerwarsViews[index]) }
		}
	}
	
	func getLayerCountByCount(warCount:Int) ->Int {
		var sumMaxWarCount = 0
		for layerIndex in 0...SummerwarsOptions.maxLayerCount {
			let maxWarCountOfLayer = getMaxCountOfLayer(layerIndex)
			sumMaxWarCount += maxWarCountOfLayer
			if(warCount <= sumMaxWarCount) {
				return layerIndex
			}
		}
		return SummerwarsOptions.maxLayerCount
	}
	
	func getMaxCountOfLayer(layerIndex:Int) ->Int {
		// calculate length of radius from center
		let layerRadius = getLayerRadius(layerIndex)
		
		// length of from space to space
		let lengthFromEventToEvent = SummerwarsOptions.warsMaxRadius * 2
		let lengthOfCircle: CGFloat = 2.0 * CGFloat(M_PI) * layerRadius
		let maxWarCount = lengthOfCircle / lengthFromEventToEvent
		
		return Int(floor(maxWarCount))
	}
	
	func getLayerRadius(layerIndex : Int) -> CGFloat{
		// find numer of radius from layerIndex (eg. 1, 2, 3)
		let numberOfRadius:CGFloat = 2.0 * CGFloat(layerIndex) + 1.0
		let outerRadius:CGFloat  = SummerwarsOptions.warsMaxRadius * numberOfRadius
		
		return SummerwarsOptions.warsCentralRadius + outerRadius
	}
	
	func getLayerRadiusBySize(warSize:Int) ->CGFloat {
		let max = SummerwarsOptions.warsMaxRadius
		let min = SummerwarsOptions.warsMinRadius
		
		var radius:CGFloat!
		if(warSize < getMaxWarSizeOfMaxCircleRadius()){
			radius = min + (max - min) * ( CGFloat(warSize)*1.5 / CGFloat(getMaxWarSizeOfMaxCircleRadius()))
		}
		else {
			radius = max
		}
		return radius
	}
	
	func getMaxWarSizeOfMaxCircleRadius() ->Int {
		return 10
	}
	
	// MARK: - Animate
	func showSummerwars(){
		UIView.animateWithDuration(0.8, delay: 2, options: .CurveEaseInOut,
			animations:  {
				self.summerwarsOprationView.transform = CGAffineTransformMakeScale(1.0, 1.0)
				self.summerwarsOprationView.alpha = 1.0
			},
			completion: {(bool: Bool) -> () in
			}
		)
	}
	
	// MARK: - UIScrollView delegate
	public func scrollViewDidScroll(scrollView: UIScrollView) {
		// get contentOffset
		let offsetPoint:CGPoint = scrollView.contentOffset
		
		// how many distance from center point of scrollview
		let dx = offsetPoint.x - ( summerwarsOprationView.frame.width - summerwarsScrollView.frame.width ) / 2.0
		let dy = offsetPoint.y - ( summerwarsOprationView.frame.height - summerwarsScrollView.frame.height ) / 2.0
		
		for index in 0..<summerwarsViews.count {
			if(index % 3 == 0){
				summerwarsViews[index].transform = CGAffineTransformMakeTranslation(dx * 0.52, dy * 0.32)
			} else if(index % 3 == 1){
				summerwarsViews[index].transform = CGAffineTransformMakeTranslation(dx * 0.26, dy * 0.24)
			}
		}
	}
	
	public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
		return summerwarsOprationView
	}
	
	public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		// set drag status
		isDraggingSpace = true
		
		// animation
		for v in summerwarsViews {
			v.doFocus()
		}
	}
	
	public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		// set drag status
		isDraggingSpace = false
		
		// animation
		for v in summerwarsViews {
			v.undoFocus()
		}
	}
}

public class WarsContent {
	public var image = UIImage()
	public var caption = ""
	
	public init(image:UIImage, caption:String = "hello"){
		self.image = image
		self.caption = caption
	}
	
}

public class WarsView: UIView{
	
	var baseView: UIView!
	var warImageView : UIImageView!
	var warTitleLabel = UILabel()
	var warTitleLabelBackground = UIControl()
	var warColor:UIColor!
	var isFocus = false
	
	public required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)!
	}
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	static func getMinCircleRadius() -> CGFloat {
		return SummerwarsOptions.warsMaxRadius * 0.6
	}
	
	func setWar(content: WarsContent) {
		setWar(content.image, caption: content.caption)
	}
	
	func setWar(image:UIImage, caption:String){
		// setup layout
		opaque = false
		warColor = randomColor(luminosity: .Light)
		
		// base view for add view
		baseView = UIView(frame: frame)
		baseView.center = CGPointMake(frame.width/2, frame.height/2)
		baseView.backgroundColor = warColor
		baseView.layer.cornerRadius = frame.width/2
		baseView.layer.masksToBounds = true
		
		// add image view
		warImageView = UIImageView(frame: CGRectMake(0, 0, frame.width, frame.height*0.42))
		warImageView.center = CGPointMake(frame.width/2, frame.height/2)
		warImageView.contentMode = .ScaleAspectFill
		warImageView.clipsToBounds = true
		warImageView.image = image
		baseView.addSubview(warImageView)
		
		// calcurate image for title
		let imageViewWidth = warImageView.frame.width
		let imageHeight = warImageView.frame.height
		let eventTitleMargin:CGFloat = 18
		
		// warTitleLabel
		warTitleLabel = UILabel(frame: CGRectMake(0, 0,
			imageViewWidth - eventTitleMargin, imageHeight))
		warTitleLabel.center = CGPointMake(warImageView.center.x, warTitleLabel.center.y )
		warTitleLabel.text = caption
		warTitleLabel.textColor = .whiteColor()
		warTitleLabel.textAlignment = .Center
		warTitleLabel.font = UIFont.boldSystemFontOfSize(18)
		warTitleLabel.lineBreakMode = .ByWordWrapping
		warTitleLabel.numberOfLines = 2
		
		// warTitleLabel Background
		warTitleLabelBackground = UIControl()
		warTitleLabelBackground.backgroundColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:0.2)
		warTitleLabelBackground.frame = CGRectMake(0, 0, imageViewWidth, imageHeight)
		warTitleLabelBackground.center = CGPointMake(warImageView.center.x, warImageView.center.y)
		
		warTitleLabelBackground.addSubview(warTitleLabel)
		baseView.addSubview(warTitleLabelBackground)
		
		addSubview(baseView)
	}
	
    // MARK: - Animate Function
    func doFocus() {
		if !isFocus {
			isFocus = true
    		UIView.animateWithDuration(0.2, animations: {
    			self.warTitleLabel.alpha = 0.0
    			self.warTitleLabelBackground.alpha = 0.0
    			}, completion: nil )
		}
	}
	
	func undoFocus() {
		if isFocus {
			isFocus = false
    		UIView.animateWithDuration(1.0, animations: {
    			self.warTitleLabel.alpha = 1.0
    			self.warTitleLabelBackground.alpha = 1.0
    			}, completion: nil )
		}
	}
}

class SummerwarsScrollView: UIScrollView {
	
	override class func layerClass() -> AnyClass {
		return CAEmitterLayer.self
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.setup()
	}
	
	private var emitter: CAEmitterLayer {
		return layer as! CAEmitterLayer
	}
	
	private var cell: CAEmitterCell!
	private var shapes = ["star", "oval", "polygon", "triangle"]
	
	func setup() {
		emitter.emitterMode = kCAEmitterLayerOutline
		emitter.emitterShape = kCAEmitterLayerCircle
		emitter.renderMode = kCAEmitterLayerOldestFirst
		emitter.preservesDepth = true
		emitter.emitterCells = []
		
		for _ in 0..<5{
			emitter.emitterCells?.append(CAEmitterCell.fast(shapes[Int.random(max: shapes.count - 1)]))
		}
		
		for _ in 0..<15 {
			emitter.emitterCells?.append(CAEmitterCell.middle(shapes[Int.random(max: shapes.count - 1)]))
		}
		
		for _ in 0..<30 {
			emitter.emitterCells?.append(CAEmitterCell.slow(shapes[Int.random(max: shapes.count - 1)]))
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		emitter.emitterPosition = CGPointMake(contentSize.width/2, contentSize.height/2)
		emitter.emitterSize = self.bounds.size
	}
}

extension CAEmitterCell {
	class func fast(shape:String) -> CAEmitterCell {
		let cell = CAEmitterCell()
		cell.contents = UIImage(named: shape)!.CGImage
		cell.color = randomColor(luminosity: .Light).CGColor
		cell.birthRate = 1
		cell.lifetime = 10
		cell.lifetimeRange = 5
		cell.velocity = 60
		cell.velocityRange = 65
		cell.scale = 0.6
		cell.scaleRange = 0.1
		cell.scaleSpeed = 0.06
		return cell
	}
	class func middle(shape:String) -> CAEmitterCell {
		let cell = CAEmitterCell()
		cell.contents = UIImage(named: shape)!.CGImage
		cell.color = randomColor(luminosity: .Light).CGColor
		cell.birthRate = 1
		cell.lifetime = 10
		cell.lifetimeRange = 5
		cell.velocity = 40
		cell.velocityRange = 45
		cell.scale = 0.6
		cell.scaleRange = 0.1
		cell.scaleSpeed = 0.06
		return cell
	}
	class func slow(shape:String) -> CAEmitterCell {
		let cell = CAEmitterCell()
		cell.contents = UIImage(named: shape)!.CGImage
		cell.color = randomColor(luminosity: .Light).CGColor
		cell.birthRate = 1
		cell.lifetime = 10
		cell.lifetimeRange = 5
		cell.velocity = 20
		cell.velocityRange = 25
		cell.scale = 0.6
		cell.scaleRange = 0.1
		cell.scaleSpeed = 0.06
		return cell
	}
}

extension Int {
	static func random(min: Int = 0, max: Int) -> Int {
		return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
	}
}


