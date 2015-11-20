//
//  SummerWars.swift
//  SummerWars
//
//  Created by suzuki_keishi on 2015/11/10.
//  Copyright © 2015年 suzuki_keishi. All rights reserved.
//

import UIKit

public class SummerWarsView: UIViewController, UIScrollViewDelegate {
	
	// UI: home
	var homeSpaceView: UIScrollView!
	var homeVirtualSpaceView: UIView = UIView() // initialized in first.
	var homeEventViews = [HomeEventView]()
	
	let maxLayerCount = 3 // 3 is property size using with eyes for iOS.
	let eventRadius:CGFloat = HomeEventView.getEventRadius()
	let innerRadius:CGFloat = HomeEventView.getEventRadius() * 0.3 // 0.3 is property size using with eyes for iOS.
	let operableZoomScale:CGFloat = 0.85
	var focusArea = (width: CGFloat(0.0), height: CGFloat(0.0))
	var homeSpaceViewScale: CGFloat = 1.0
	
	// property
	var isInitializedViews = false
	var isReadyToAnimateEvents = true
	var isDraggingSpace = false
	
	required public init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	convenience init() {
		self.init(nibName: nil, bundle: nil)
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nil, bundle: nil)
		setup()
	}
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		
		// call home view first.
		setupHomeView()
		// setup for animation
		isInitializedViews = true
		animateEventsForAppear()
	}
	
	private func setup() {
		
	}
	
	public override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(true)
		
		// for animation
		isReadyToAnimateEvents = true
	}
	
	private func setupHomeView() {
		// create scrollview
		homeSpaceView = SummerwarsBackgroundView(frame: CGRectMake(0, 0, view.frame.width, view.frame.height))
		homeSpaceView.delegate = self
		homeSpaceView.maximumZoomScale = 1.2
		homeSpaceView.minimumZoomScale = 0.7
		homeSpaceView.showsHorizontalScrollIndicator = false
		homeSpaceView.showsVerticalScrollIndicator = false
		homeSpaceView.pagingEnabled = false
		homeSpaceView.directionalLockEnabled = false
		homeSpaceView.backgroundColor = .clearColor()
		
		view.addSubview(homeSpaceView)
		
		// add focus area for animate
		focusArea = (width: homeSpaceView.frame.width * 0.4, height: homeSpaceView.frame.height * 0.4)
		
		// create home space.
		createHomeSpace()
	}
	
	func createHomeSpace() {
		
		// create virtual view dynamically
		let layerCount = getLayerCountByRoomCount(30)
		let lastLayerRadius = getLayerRadius(layerCount + 1) // + 1 is for space for outer
		
		// calcrate dynamic space size. (diameter of mexlayer) + outer white space
		var virtualSpaceSize = (lastLayerRadius * 2.0) + view.frame.width/2
		// if dynamic view size is smaller than device height, make scale up for scrolling
		if virtualSpaceSize < homeSpaceView.frame.height * 2.0 {
			virtualSpaceSize = homeSpaceView.frame.height * 2.0
		}
		let centerVirtualSpace = CGPointMake(virtualSpaceSize/2.0, virtualSpaceSize/2.0)
		
		// calcurate center point of scroll view
		let upLeftX = virtualSpaceSize/2 - homeSpaceView.frame.width/2
		let upLeftY = virtualSpaceSize/2 - homeSpaceView.frame.height/2
		
		homeVirtualSpaceView.backgroundColor = UIColor.yellowColor()
		homeVirtualSpaceView = UIView(frame: CGRectMake(0, 0, virtualSpaceSize, virtualSpaceSize))
		homeVirtualSpaceView.transform = CGAffineTransformMakeScale(0.3, 0.3)
		homeVirtualSpaceView.alpha = 0.5
		
		homeSpaceView.contentSize = homeVirtualSpaceView.bounds.size
		homeSpaceView.setContentOffset(CGPointMake(upLeftX, upLeftY), animated: false)
		homeSpaceView.addSubview(homeVirtualSpaceView)
		
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
				roomCountOfLayer = 30 - roomCountIndex
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
				
				// image
				let bundle = NSBundle(forClass: SummerWarsView.self)
				let image = UIImage(named: "SummerWars.bundle/images/image\(Int.random(max: 17)).jpg", inBundle: bundle, compatibleWithTraitCollection: nil) ?? UIImage()
				
				let r = getLayerRadiusByRoomSize(Int.random(max: getMaxRoomSizeOfMaxCircleRadius()))
				let homeEventView = HomeEventView()
				homeEventView.frame = CGRectMake(0.0, 0.0, r*2.0, r*2.0)
				homeEventView.center = CGPointMake(centerX, centerY)
				homeEventView.setEvent(image)
				
				//create transParent Button For segue
				var btn = UIButton(frame: CGRectMake(0.0, 0.0, homeEventView.frame.width, homeEventView.frame.height))
				homeEventView.addSubview(btn)
				
				// add to local cache
				homeEventViews.append(homeEventView)
				
				// add to view
				homeVirtualSpaceView.addSubview(homeEventView)
				
				roomCountIndex++
			}
		}
		
		// this is what we can see like a 3D view
		for index in 0..<homeEventViews.count {
			if(index % 3 == 1){ homeVirtualSpaceView.bringSubviewToFront(homeEventViews[index]) }
		}
		for index in 0..<homeEventViews.count {
			if(index % 3 == 2){ homeVirtualSpaceView.bringSubviewToFront(homeEventViews[index]) }
		}
	}
	
	func getLayerCountByRoomCount(roomCount:Int) ->Int {
		var sumMaxRoomCount = 0
		for layerIndex in 0...maxLayerCount {
			let maxRoomCountOfLayer = getMaxRoomCountOfLayer(layerIndex)
			sumMaxRoomCount += maxRoomCountOfLayer
			if(roomCount <= sumMaxRoomCount) {
				return layerIndex
			}
		}
		return maxLayerCount
	}
	
	func getMaxRoomCountOfLayer(layerIndex:Int) ->Int {
		// calculate length of radius from center
		let layerRadius = getLayerRadius(layerIndex)
		
		// length of from space to space
		let lengthFromEventToEvent = eventRadius * 2
		let lengthOfCircle: CGFloat = 2.0 * CGFloat(M_PI) * layerRadius
		
		let maxRoomCount = lengthOfCircle / lengthFromEventToEvent
		
		return Int(floor(maxRoomCount))
	}
	
	func getLayerRadius(layerIndex : Int) -> CGFloat{
		// find numer of radius from layerIndex (eg. 1, 2, 3)
		let numberOfRadius:CGFloat = 2.0 * CGFloat(layerIndex) + 1.0
		let outerRadius:CGFloat  = eventRadius * numberOfRadius
		
		return innerRadius + outerRadius
	}
	
	// "room size" is not people count. size is defined at server. eg. 1,2,3..
	func getLayerRadiusByRoomSize(roomSize:Int) ->CGFloat {
		let max = HomeEventView.getMaxCircleRadius()
		let min = HomeEventView.getMinCircleRadius()
		
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
			UIView.animateWithDuration( 0.8, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut,
				animations:  {[weak self]() -> () in
					if let _self = self {
						_self.homeVirtualSpaceView.transform = CGAffineTransformMakeScale(1.0, 1.0)
						_self.homeVirtualSpaceView.alpha = 1.0
					}
				},
				completion: {[weak self](bool: Bool) -> () in
					if let _self = self {
						_self.animateIfFocus()
						_self.isReadyToAnimateEvents = true
					}
				}
			)
		}
	}
	
	func animateIfFocus() {
		if isInitializedViews && !isDraggingSpace {
			// center[X,Y] is dynamical center position.
			let centerX = (homeSpaceView.bounds.origin.x + homeSpaceView.frame.width)/homeSpaceViewScale
			let centerY = (homeSpaceView.bounds.origin.y + homeSpaceView.frame.height)/homeSpaceViewScale
			
			for homeEvent in homeEventViews {
				
				// absolute distance from event point
				let dx = abs(centerX - homeEvent.center.x)
				let dy = abs(centerY - homeEvent.center.y)
				
				if(dx < focusArea.width/homeSpaceViewScale && dy < focusArea.height/homeSpaceViewScale){
				} else {
				}
			}
		}
	}
	
	// MARK: - UIScrollView Delpublic egate
	public func scrollViewDidScroll(scrollView: UIScrollView) {
		animateIfFocus()
		
		// get contentOffset
		let offsetPoint:CGPoint = scrollView.contentOffset
		
		// how many distance from center point of scrollview
		let dx = offsetPoint.x - ( homeVirtualSpaceView.frame.width - homeSpaceView.frame.width ) / 2.0
		let dy = offsetPoint.y - ( homeVirtualSpaceView.frame.height - homeSpaceView.frame.height ) / 2.0
		
		for index in 0..<homeEventViews.count {
			if(index % 3 == 0){
				homeEventViews[index].transform = CGAffineTransformMakeTranslation(dx * 0.52, dy * 0.32)
//				homeEventViews[index].transform = CGAffineTransformMakeTranslation(dx * 0.22, dy * 0.18)
			} else if(index % 3 == 1){
				homeEventViews[index].transform = CGAffineTransformMakeTranslation(dx * 0.26, dy * 0.24)
			}
		}
	}
	
	public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
		return homeVirtualSpaceView
	}
	
	public func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView!, atScale scale: CGFloat) {
		//set zoomingScale
		homeSpaceViewScale = scale
	}
	
	public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		// set drag status
		isDraggingSpace = true
	
	}
	
	public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		// set drag status
		isDraggingSpace = false
		animateIfFocus()
	}
}




class HomeEventView: UIView {
	
	// Layout Property
	let ownerDiameter:CGFloat = 44.0
	
	var followIconImageView: UIImageView!
	// UI
	var baseView: UIView!
	var eventImageView : UIImageView!
	var eventTitleLabel = UILabel()
	var eventTitleLabelBackground = UIControl()
	// Property
	var userDeployedPoint = [Int]()
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)!
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	class func getMaxCircleRadius() -> CGFloat {
		return UIScreen.mainScreen().bounds.size.width * 0.3
	}
	
	class func getMinCircleRadius() -> CGFloat {
		return getMaxCircleRadius() * 0.6
	}
	
	class func getEventRadius() -> CGFloat {
		return getMaxCircleRadius()
	}
	
	// MARK: - add to layout
	func setEvent(image: UIImage) {
		
		// setup layout
		opaque = false
		
		// base view for add view
		baseView = UIView(frame: frame)
		baseView.center = CGPointMake(frame.width/2, frame.height/2)
		baseView.backgroundColor = randomColor(luminosity: .Light)
		baseView.layer.cornerRadius = frame.width/2
		baseView.layer.masksToBounds = true
		
		// add video image view
		eventImageView = UIImageView(frame: CGRectMake(0, 0, frame.width, frame.height*0.42))
		eventImageView.center = CGPointMake(frame.width/2, frame.height/2)
		eventImageView.contentMode = UIViewContentMode.ScaleAspectFill
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
		eventTitleLabel.text = "Hello world."
		eventTitleLabel.textColor = UIColor.whiteColor()
		eventTitleLabel.textAlignment = NSTextAlignment.Center
		eventTitleLabel.numberOfLines = 2
		eventTitleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
		
		// eventTitleLabel Background
		eventTitleLabelBackground = UIControl()
		eventTitleLabelBackground.backgroundColor = UIColor(red:0.0,green:0.0,blue:0.0,alpha:0.5)
		eventTitleLabelBackground.frame = CGRectMake(0, 0, imageViewWidth, imageHeight)
		eventTitleLabelBackground.center = CGPointMake(eventImageView.center.x, eventImageView.center.y)
		
		eventTitleLabelBackground.addSubview(eventTitleLabel)
		baseView.addSubview(eventTitleLabelBackground)
		
		addSubview(baseView)
	}
}

class SummerwarsBackgroundView: UIScrollView {
	
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
	
	private var particle: CAEmitterCell!
	
	//http://breaktimes.hatenablog.com/entry/2015/05/14/175747
	func setup() {
		emitter.emitterMode = kCAEmitterLayerOutline
		emitter.emitterShape = kCAEmitterLayerCircle
		emitter.renderMode = kCAEmitterLayerOldestFirst
		emitter.preservesDepth = true
		emitter.emitterCells = []
		
		for _ in 0..<10 {
    		particle = CAEmitterCell()
    		particle.contents = UIImage(named: "spark")!.CGImage
    		particle.color = randomColor(luminosity: .Light).CGColor
    		particle.birthRate = 10
    		particle.lifetime = 50
    		particle.lifetimeRange = 5
    		particle.velocity = 20
    		particle.velocityRange = 30
    		particle.scale = 0.02
    		particle.scaleRange = 0.1
    		particle.scaleSpeed = 0.006
			emitter.emitterCells?.append(particle)
		}
	}
	
	var emitterTimer: NSTimer?
	
	override func didMoveToWindow() {
		super.didMoveToWindow()
		
		if self.window != nil {
			if emitterTimer == nil {
				emitterTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "randomizeEmitterPosition", userInfo: nil, repeats: true)
			}
		} else if emitterTimer != nil {
			emitterTimer?.invalidate()
			emitterTimer = nil
		}
	}
	
	func randomizeEmitterPosition() {
		emitter.emitterPosition = CGPointMake(CGFloat(arc4random()) % contentSize.width/2,
											  CGFloat(arc4random()) %	contentSize.height/2)
		particle.birthRate = 10
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		emitter.emitterPosition = CGPointMake(contentSize.width/2, contentSize.height/2)
		emitter.emitterSize = self.bounds.size
	}
}

extension Int {
	static func random(min: Int = 0, max: Int) -> Int {
		return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
	}
}
