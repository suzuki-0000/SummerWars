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
	var summerwarsScrollView: SummerwarsScrollView!
	var summerwarsOprationView: UIView = UIView() // initialized in first.
	var summerwarsViews = [WarsView]()
	
	let maxViewCount = 30
	let maxLayerCount = 3 // 3 is property size using with eyes for iOS.
	let eventRadius:CGFloat = WarsView.getEventRadius()
	let innerRadius:CGFloat = WarsView.getEventRadius() * 0.3 // 0.3 is property size using with eyes for iOS.
	let operableZoomScale:CGFloat = 0.65
	var focusArea = (width: CGFloat(0.0), height: CGFloat(0.0))
	var summerwarsScrollViewScale: CGFloat = 1.0
	
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
		
		// add focus area for animate
		focusArea = (width: summerwarsScrollView.frame.width * 0.4, height: summerwarsScrollView.frame.height * 0.4)
		
		// create home space.
		createHomeSpace()
	}
	
	func createHomeSpace() {
		
		// create virtual view dynamically
		let layerCount = getLayerCountByRoomCount(maxViewCount)
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
		summerwarsOprationView.transform = CGAffineTransformMakeScale(0.3, 0.3)
		summerwarsOprationView.alpha = 0.5
		
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
				roomCountOfLayer = maxViewCount - roomCountIndex
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
				let summerwarsView = WarsView()
				summerwarsView.frame = CGRectMake(0.0, 0.0, r*2.0, r*2.0)
				summerwarsView.center = CGPointMake(centerX, centerY)
				summerwarsView.setEvent(image)
				
				//create transParent Button For segue
				let btn = UIButton(frame: CGRectMake(0.0, 0.0, summerwarsView.frame.width, summerwarsView.frame.height))
				btn.addTarget(self, action: "startWars:", forControlEvents: .TouchUpInside)
				summerwarsView.addSubview(btn)
				
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
			UIView.animateWithDuration( 0.8, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut,
				animations:  {[weak self]() -> () in
					if let _self = self {
						_self.summerwarsOprationView.transform = CGAffineTransformMakeScale(1.0, 1.0)
						_self.summerwarsOprationView.alpha = 1.0
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
			let centerX = (summerwarsScrollView.bounds.origin.x + summerwarsScrollView.frame.width)/summerwarsScrollViewScale
			let centerY = (summerwarsScrollView.bounds.origin.y + summerwarsScrollView.frame.height)/summerwarsScrollViewScale
			
			for v in summerwarsViews {
				
				// absolute distance from event point
				let dx = abs(centerX - v.center.x)
				let dy = abs(centerY - v.center.y)
				
				if(dx < focusArea.width/summerwarsScrollViewScale && dy < focusArea.height/summerwarsScrollViewScale){
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
	
	public func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView!, atScale scale: CGFloat) {
		//set zoomingScale
		summerwarsScrollViewScale = scale
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
	
	let transitionManager = TransitionManager()
	public func startWars(button:UIButton){
		guard let warsView = button.superview as? WarsView else {
			return
		}
		// hello 
		let vc = SummerwarsSecondViewController()
		vc.warsView = warsView
		vc.transitioningDelegate = transitionManager
		transitionManager.warsView = warsView
		transitionManager.parentView = summerwarsScrollView
		
		presentViewController(vc, animated: true, completion: {})
	}
}

class SummerwarsSecondViewController:UIViewController{
	
	var warsView: WarsView!
	
	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = warsView.eventColor
		
		let imageView = UIImageView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, warsView.frame.height))
		imageView.center = CGPointMake(view.frame.width/2, view.frame.height/2)
		imageView.image = warsView.eventImageView.image
		view.addSubview(imageView)
		
		let dismissButton = UIButton()
		dismissButton.frame = CGRectMake(0, 0, 40, 40)
		dismissButton.addTarget(self, action: "dismissButton:", forControlEvents: .TouchUpInside)
		view.addSubview(dismissButton)
	}
	
	public func dismissButton(btn: UIButton){
		dismissViewControllerAnimated(true, completion: {})
	}
}

class WarsView: UIView{
	
	// UI
	var baseView: UIView!
	var eventImageView : UIImageView!
	var eventTitleLabel = UILabel()
	var eventTitleLabelBackground = UIControl()
	var eventColor:UIColor!
	var isFocus = false
	
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
		eventTitleLabel.text = "Hello world."
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
	
	//http://breaktimes.hatenablog.com/entry/2015/05/14/175747
	func setup() {
		emitter.emitterMode = kCAEmitterLayerOutline
		emitter.emitterShape = kCAEmitterLayerCircle
		emitter.renderMode = kCAEmitterLayerOldestFirst
		emitter.preservesDepth = true
		emitter.emitterCells = []
		
		for _ in 0..<10 {
    		cell = CAEmitterCell()
    		cell.contents = UIImage(named: "spark")!.CGImage
    		cell.color = randomColor(luminosity: .Light).CGColor
    		cell.birthRate = 10
    		cell.lifetime = 50
    		cell.lifetimeRange = 5
    		cell.velocity = 20
    		cell.velocityRange = 25
    		cell.scale = 0.02
    		cell.scaleRange = 0.002
    		cell.scaleSpeed = 0.006
			emitter.emitterCells?.append(cell)
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
											  CGFloat(arc4random()) % contentSize.height/2)
		cell.birthRate = 10
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		emitter.emitterPosition = CGPointMake(contentSize.width/2, contentSize.height/2)
		emitter.emitterSize = self.bounds.size
	}
}

class TransitionCircleView: UIView{
	
	var myColor:UIColor!
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = UIColor.clearColor()
		myColor = UIColor.whiteColor()
	}
	
	override func drawRect(rect: CGRect) {
		let oval = UIBezierPath(ovalInRect: self.bounds)
		myColor.setFill()
		oval.fill()
	}
	
}

class TransitionManager: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate{
	
	var presenting = true
	var duration: NSTimeInterval = 1.5
	var delay: NSTimeInterval = 0.5
	var dump:CGFloat = 0.5
	var velocity:CGFloat = 0.8
	var startFrame: CGRect!
	var color: UIColor!
	
	var parentView:UIScrollView!
	var warsView:WarsView!
	
	override init(){
	}
	
	init(parentView:UIScrollView, warsView:WarsView){
		self.parentView = parentView
		self.warsView = warsView
	}
	
	// MARK: UIViewControllerAnimatedTransitioning
	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
		
		let containerView = transitionContext.containerView()
		let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
		let toVC   = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
		let fromView = fromVC.view
		let toView = toVC.view
		transitionIntoRoom(fromView, toView: toView, containerView: containerView!, transitionContext: transitionContext)
	}
	
	func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
		return duration
	}
	
	// MARK: UIViewControllerTransitioningDelegate
	
	func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		self.presenting = true
		return self
	}
	
	func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		presenting = false
		return self
	}
	
	func navigationController(navigationController: UINavigationController,
		animationControllerForOperation operation: UINavigationControllerOperation,
		fromViewController fromVC: UIViewController,
		toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
			if operation == UINavigationControllerOperation.Pop {
				presenting = false
			}
			
			return self
	}
	
	private func transitionIntoRoom(fromView: UIView,
		toView: UIView,
		containerView: UIView,
		transitionContext: UIViewControllerContextTransitioning) {
			
			containerView.addSubview(toView)
			containerView.addSubview(fromView)
			
			// set transition center
			let x = (-parentView.contentOffset.x) + warsView.center.x * parentView.zoomScale
			let y = (-parentView.contentOffset.y)  + warsView.center.y * parentView.zoomScale
			
			let frame = CGRectMake(warsView.frame.origin.x, warsView.frame.origin.y,
				warsView.frame.width*parentView.zoomScale,
				warsView.frame.height*parentView.zoomScale)
			
			let transitionCircle = TransitionCircleView(frame: frame)
			transitionCircle.myColor = warsView.eventColor
			transitionCircle.center = CGPointMake(x, y)
			containerView.addSubview(transitionCircle)
			
			let frameLabel = CGRectMake(warsView.eventTitleLabel.frame.origin.x,
				warsView.eventTitleLabel.frame.origin.y,
				warsView.eventTitleLabel.frame.width  * parentView.zoomScale,
				warsView.eventTitleLabel.frame.height * parentView.zoomScale)
			
			let transitionRect = UIImageView(frame: frameLabel)
			transitionRect.backgroundColor = UIColor.blackColor()
			transitionRect.center = CGPointMake(x, y)
			transitionRect.image = warsView.eventImageView.image
			containerView.addSubview(transitionRect)
			
			let scale = fromView.frame.height * 2.8 / transitionCircle.frame.height
			let movieWidth = fromView.frame.width
			let movieHeight = fromView.frame.width * 0.6
			
			let durationRatio:CGFloat = 1.3
			let d = 0.35 * durationRatio
			
			if presenting {
				// this is scale small a bit
				warsView.alpha = 0
				
				// transition
				transitionCircle.transform = CGAffineTransformMakeScale(1, 1)
				transitionRect.transform = CGAffineTransformMakeScale(1, 1)
				
				// then zoom in
				UIView.animateWithDuration(NSTimeInterval(d), delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn,
					animations: {
						// transition
						transitionCircle.transform = CGAffineTransformMakeScale(scale, scale)
						transitionRect.transform = CGAffineTransformMakeScale(1, 1)
						transitionRect.frame = CGRectMake(0, 0, movieWidth, movieHeight)
						transitionRect.center = CGPointMake(toView.frame.width/2, toView.frame.height/2)
					},
					completion: {(bool: Bool) -> () in
						self.warsView.alpha = 1
						// remove
						fromView.removeFromSuperview()
						transitionRect.removeFromSuperview()
						transitionCircle.removeFromSuperview()
						transitionContext.completeTransition(true)
					}
				)
				
			} else {
				warsView.alpha = 1
				
				transitionRect.frame = CGRectMake(0, 55, movieWidth, movieHeight)
				
				// transition
				transitionCircle.transform = CGAffineTransformMakeScale(scale, scale)
				transitionRect.transform = CGAffineTransformMakeScale(1, 1)
				
				// then zoom in
				UIView.animateWithDuration(NSTimeInterval(d), delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn,
					animations: {
						// transition
						transitionCircle.transform = CGAffineTransformMakeScale(1, 1)
						transitionRect.transform = CGAffineTransformMakeScale(1, 1)
						transitionRect.frame = frameLabel
						transitionRect.center = CGPointMake(x, y)
					},
					completion: {(bool: Bool) -> () in
						self.warsView.alpha = 1
						// remove
						fromView.removeFromSuperview()
						transitionRect.removeFromSuperview()
						transitionCircle.removeFromSuperview()
						transitionContext.completeTransition(true)
					}
				)
				
			}
			
	}
}

extension Int {
	static func random(min: Int = 0, max: Int) -> Int {
		return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
	}
}
