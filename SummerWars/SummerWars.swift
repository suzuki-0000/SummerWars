//
//  SummerWars.swift
//  SummerWars
//
//  Created by suzuki_keishi on 2015/11/10.
//  Copyright © 2015年 suzuki_keishi. All rights reserved.
//

import UIKit

public struct Settings{
    public static var maxViewCount = 30
    public static var maxLayerCount = 3 // 3 is property size using with eyes for iOS.
    public static var warsRadius:CGFloat = WarsView.getWarsRadius()
    public static var warsCentralRadius:CGFloat = WarsView.getWarsRadius() * 0.3 // 0.3 is property size using with eyes for iOS.
}

public class SummerWarsViewController: UIViewController, UIScrollViewDelegate {
	
	
	var summerwarsScrollView: SummerwarsScrollView!
	var summerwarsOprationView: UIView = UIView() // initialized in first.
	var summerwarsViews = [WarsView]()
	var warsContents = [WarsContent]()
	
	private var isInitializedViews = false
	private var isReadyToAnimateEvents = true
	private var isDraggingSpace = false
	private var viewCount: Int {
		if warsContents.count > 0 {
			return warsContents.count
		}
		return Settings.maxViewCount
	}
	
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
		setupHomeView()
		// setup for animation
		isInitializedViews = true
		animateEventsForAppear()
	}
	
	public override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(true)
		
		// for animation
		isReadyToAnimateEvents = true
	}
	
	private func setupHomeView() {
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
		let layerCount = getLayerCountByRoomCount(viewCount)
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
		
		var roomCountIndex = 0
		// layerCount is calcurated by event count
		// 1. loop layercount which is calcurated by event.count, request from server ( eg. 1.2.3.. 15 )
		// 2. loop roomCount for each layer whici is calculated by layer. (eg. 3, 7, 14..)
		for layerIndex in 0...layerCount {
			// get room count for each layer
			let currentLayerOfMaxRoomCount = getMaxRoomCountOfLayer(layerIndex)
			let currentLayerRadius = getLayerRadius(layerIndex)
			
			var roomCountOfLayer:Int!
			if layerIndex == layerCount{
				// count room if it is last layer
				roomCountOfLayer = viewCount - roomCountIndex
			} else {
				// not the end of layer, apply max room count
				roomCountOfLayer = currentLayerOfMaxRoomCount
			}
			
			// 2π / roomcount = theta.
			let theta = 2.0 * M_PI / Double(roomCountOfLayer)
			// this is for random views
			let diffTheta: Double = Double( rand() / 10 ) / 10.0
			
			for eventPoint in 0..<roomCountOfLayer {
				
				// pin [x/y] center point from cos(theta * hypotenuse of event point), sin(theta * hypotenuse)
				let centerX = centerVirtualSpace.x + currentLayerRadius * CGFloat(cos(diffTheta + theta * Double(eventPoint)))
				let centerY = centerVirtualSpace.y + currentLayerRadius * CGFloat(sin(diffTheta + theta * Double(eventPoint)))
				
				let r = getLayerRadiusByRoomSize(Int.random(max: getMaxRoomSizeOfMaxCircleRadius()))
				let summerwarsView = WarsView()
				summerwarsView.frame = CGRectMake(0.0, 0.0, r*2.0, r*2.0)
				summerwarsView.center = CGPointMake(centerX, centerY)
				
				// image
				if warsContents.count > 0 {
					let image = warsContents[roomCountIndex]
    				summerwarsView.setWar(image)
				} else {
    				summerwarsView.setWar()
				}
				
				// add to local cache
				summerwarsViews.append(summerwarsView)
				
				// add to view
				summerwarsOprationView.addSubview(summerwarsView)
				
				roomCountIndex++
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
	
	func getLayerCountByRoomCount(roomCount:Int) ->Int {
		var sumMaxRoomCount = 0
		for layerIndex in 0...Settings.maxLayerCount {
			let maxRoomCountOfLayer = getMaxRoomCountOfLayer(layerIndex)
			sumMaxRoomCount += maxRoomCountOfLayer
			if(roomCount <= sumMaxRoomCount) {
				return layerIndex
			}
		}
		return Settings.maxLayerCount
	}
	
	func getMaxRoomCountOfLayer(layerIndex:Int) ->Int {
		// calculate length of radius from center
		let layerRadius = getLayerRadius(layerIndex)
		
		// length of from space to space
		let lengthFromEventToEvent = Settings.warsRadius * 2
		let lengthOfCircle: CGFloat = 2.0 * CGFloat(M_PI) * layerRadius
		let maxRoomCount = lengthOfCircle / lengthFromEventToEvent
		
		return Int(floor(maxRoomCount))
	}
	
	func getLayerRadius(layerIndex : Int) -> CGFloat{
		// find numer of radius from layerIndex (eg. 1, 2, 3)
		let numberOfRadius:CGFloat = 2.0 * CGFloat(layerIndex) + 1.0
		let outerRadius:CGFloat  = Settings.warsRadius * numberOfRadius
		
		return Settings.warsCentralRadius + outerRadius
	}
	
	// "room size" is not people count. size is defined at server. eg. 1,2,3..
	func getLayerRadiusByRoomSize(roomSize:Int) ->CGFloat {
		let max = WarsView.getMaxCircleRadius()
		let min = WarsView.getMinCircleRadius()
		
		var radius:CGFloat!
		if(roomSize < getMaxRoomSizeOfMaxCircleRadius()){
			radius = min + (max - min) * ( CGFloat(roomSize)*1.5 / CGFloat(getMaxRoomSizeOfMaxCircleRadius()))
		}
		else {
			radius = max
		}
		return radius
	}
	
	func getMaxRoomSizeOfMaxCircleRadius() ->Int {
		return 10
	}
	
	// MARK: - Animate
	func animateEventsForAppear(){
		if isReadyToAnimateEvents {
			isReadyToAnimateEvents = false
			UIView.animateWithDuration(0.8, delay: 1, options: .CurveEaseInOut,
				animations:  {[weak self]() -> () in
					if let _self = self {
						_self.summerwarsOprationView.transform = CGAffineTransformMakeScale(1.0, 1.0)
						_self.summerwarsOprationView.alpha = 1.0
					}
				},
				completion: {[weak self](bool: Bool) -> () in
					if let _self = self {
						_self.isReadyToAnimateEvents = true
					}
				}
			)
		}
	}
	
	// MARK: - UIScrollView Delpublic egate
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
	
	public init(image:UIImage, caption:String = ""){
		self.image = image
		self.caption = caption
	}
	
}

public class WarsView: UIView{
	
	// UI
	var baseView: UIView!
	var eventImageView : UIImageView!
	var eventTitleLabel = UILabel()
	var eventTitleLabelBackground = UIControl()
	var eventColor:UIColor!
	var isFocus = false
	
	public required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)!
	}
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	static func getMaxCircleRadius() -> CGFloat {
		return UIScreen.mainScreen().bounds.size.width * 0.3
	}
	
	static func getMinCircleRadius() -> CGFloat {
		return getMaxCircleRadius() * 0.6
	}
	
	static func getWarsRadius() -> CGFloat {
		return getMaxCircleRadius()
	}
	
	// for example
	func setWar(){
		let bundle = NSBundle(forClass: SummerWarsViewController.self)
		let image = UIImage(named: "SummerWars.bundle/images/image\(Int.random(max: 17)).jpg", inBundle: bundle, compatibleWithTraitCollection: nil) ?? UIImage()
		setWar(image, caption: "hello world.")
	}
	
	func setWar(content: WarsContent) {
		setWar(content.image, caption: content.caption)
	}
	
	func setWar(image:UIImage, caption:String){
		// setup layout
		opaque = false
		eventColor = randomColor(luminosity: .Light)
		
		// base view for add view
		baseView = UIView(frame: frame)
		baseView.center = CGPointMake(frame.width/2, frame.height/2)
		baseView.backgroundColor = eventColor
		baseView.layer.cornerRadius = frame.width/2
		baseView.layer.masksToBounds = true
		
		// add video image view
		eventImageView = UIImageView(frame: CGRectMake(0, 0, frame.width, frame.height*0.42))
		eventImageView.center = CGPointMake(frame.width/2, frame.height/2)
		eventImageView.contentMode = .ScaleAspectFill
		eventImageView.clipsToBounds = true
		eventImageView.image = image
		baseView.addSubview(eventImageView)
		
		// calcurate image size after completion.
		let imageViewWidth = eventImageView.frame.width
		let imageHeight = eventImageView.frame.height
		let eventTitleMargin:CGFloat = 18
		
		// eventTitleLabel
		eventTitleLabel = UILabel(frame: CGRectMake(0, 0,
			imageViewWidth - eventTitleMargin, imageHeight))
		eventTitleLabel.center = CGPointMake(eventImageView.center.x, eventTitleLabel.center.y )
		eventTitleLabel.text = caption
		eventTitleLabel.textColor = .whiteColor()
		eventTitleLabel.textAlignment = .Center
		eventTitleLabel.lineBreakMode = .ByWordWrapping
		eventTitleLabel.numberOfLines = 2
		
		// eventTitleLabel Background
		eventTitleLabelBackground = UIControl()
		eventTitleLabelBackground.backgroundColor = UIColor(red:0.0,green:0.0,blue:0.0,alpha:0.5)
		eventTitleLabelBackground.frame = CGRectMake(0, 0, imageViewWidth, imageHeight)
		eventTitleLabelBackground.center = CGPointMake(eventImageView.center.x, eventImageView.center.y)
		
		eventTitleLabelBackground.addSubview(eventTitleLabel)
		baseView.addSubview(eventTitleLabelBackground)
		
		addSubview(baseView)
	}
	
	// MARK: - Animate Function
func doFocus() {
		if !isFocus {
			isFocus = true
    		UIView.animateWithDuration(0.2, animations: {() -> Void in
    			self.eventTitleLabel.alpha = 0.0
    			self.eventTitleLabelBackground.alpha = 0.0
    			}, completion: {(Bool) -> () in
    		})
		}
	}
	
	func undoFocus() {
		if isFocus {
			isFocus = false
    		UIView.animateWithDuration(1.0, animations: {() -> Void in
    			self.eventTitleLabel.alpha = 1.0
    			self.eventTitleLabelBackground.alpha = 1.0
    			}, completion: {(Bool) -> () in
    		})
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


