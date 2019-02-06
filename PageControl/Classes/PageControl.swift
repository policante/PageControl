//
//  PageControl.swift
//  PageControl
//
//  Created by Rodrigo Martins on 09/06/2017.
//  Copyright (c) 2017 Rodrigo Martins. All rights reserved.
//
import UIKit

public protocol PageControlDelegate{
    
    func pageControl(_ pageController: PageControlViewController, atSelected viewController: UIViewController)
    
    func pageControl(_ pageController: PageControlViewController, atUnselected viewController: UIViewController)
}

@objc public protocol PageControlDataSource{
    
    @objc optional func pageControl(_ pageController: PageControlViewController, sizeAtRow row: Int) -> CGSize
	
	@objc optional func pageControl(_ pageController: PageControlViewController, willShow viewController: UIViewController)
	
	@objc optional func pageControl(_ pageController: PageControlViewController, didShow viewController: UIViewController)
    
    func numberOfCells(in pageController: PageControlViewController) -> Int
    
    func pageControl(_ pageController: PageControlViewController, cellAtRow row: Int) -> UIViewController
    
}

public class PageControlViewController: UIViewController, UICollectionViewDelegate {
    
    open var delegate: PageControlDelegate? = nil
	open var dataSource: PageControlDataSource? = nil
    
    open var animation: UIViewAnimationCurve = .easeInOut
    open var animationSpeed: TimeInterval = 1
	
	fileprivate var oldPosition: Int = 0
	fileprivate var currentPos : Int = 0 {
		willSet{
			self.oldPosition = currentPos
		}
	}
	fileprivate var currentPage: [StepPage: UIViewController?] = [:]
	
	internal enum StepPage {
		case prev
		case current
		case next
	}
	
	internal enum PageFlow {
		case left
		case rigth
		case nothing
	}
	
	open var infiniteMode: Bool = false {
		didSet{
			updateData()
		}
	}
	
	open var count: Int {
		if let dataSource = self.dataSource {
			return dataSource.numberOfCells(in: self)
		}
		return 0
	}
	
    open var currentPosition: Int {
		get{
			return currentPos
		}
		set{
			if newValue >= 0 , newValue < self.count {
				let oldPosition = currentPos
				currentPos = newValue
				
				if currentPos > oldPosition {
					self.setupViews(flow: .rigth)
				}else if currentPos < oldPosition {
					self.setupViews(flow: .left)
				}else{
					self.setupViews(flow: .nothing)
				}
				
			}
		}
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
		
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(PageControlViewController.slideToRightGestureRecognizer(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(PageControlViewController.slideToLeftGestureRecognizer(_:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
		
		self.updateData()
    }
	
    open func updateData(){
		self.currentPage.removeAll()
	
		for vc in self.childViewControllers {
			remove(viewController: vc, multiplier: 0, animation: false)
		}
		
		guard self.count > 0 else {
			return
		}
		
        if self.currentPos >= self.count {
            self.currentPos = self.count - 1
        }
        
        if self.currentPos <= 0 {
            self.currentPos = 0
        }

        self.setupViews(flow: .nothing)
		
    }
    
    open func nextPage(){
		let oldPosition = currentPos
		if (currentPos + 1) < self.count {
			currentPos += 1
		}else{
			if infiniteMode {
				currentPos = 0
			}
		}
		if oldPosition != currentPos {
			self.setupViews(flow: .rigth)
		}
    }
    
    open func previousPage(){
		let oldPosition = currentPos
		if (currentPos - 1) >= 0 {
			currentPos -= 1
		}else{
			if infiniteMode {
				currentPos = count
			}
		}
		if oldPosition != currentPos {
			self.setupViews(flow: .left)
		}
    }
    
	fileprivate func setupViews(flow: PageFlow){
		guard let dataSource = self.dataSource else {
			return
		}
		
		print("\(self.currentPos)")
		
		switch flow{
		case .left:
			flowToLeft()
			break
		case .rigth:
			flowToRight()
			break
		default:
			break
		}
		
		if self.currentPage[.current]??.parent == nil {
			let vc = dataSource.pageControl(self, cellAtRow: self.currentPos)
			vc.view.frame.size = dataSource.pageControl?(self, sizeAtRow: self.currentPos) ?? self.view.bounds.size
			self.currentPage[.current] = vc
		}
		
		if self.currentPage[.prev] == nil {
			self.buildPrevController()
		}
		
		if self.currentPage[.next] == nil {
			self.buildNextController()
		}
		
		
		for (step, page) in self.currentPage{
			if let viewController = page {
						var multiplier: CGFloat
						switch step {
						case .prev:
							multiplier = -1
							break
						case .current:
							multiplier = 0
							break
						case .next:
							multiplier = 1
							break
						}
				addViewController(viewController: viewController, multiplier: multiplier)
			}
			
		}
    }
	
	private func addViewController(viewController vc: UIViewController, multiplier: CGFloat, animation: Bool = true){
		var newAttached = false
		var skipAnimation = false
		
		if vc.parent == nil {
			newAttached = true
			self.addChildViewController(vc)
			self.view.addSubview(vc.view)
			vc.didMove(toParentViewController: self)
		}
		
		let pageSize = vc.view.frame.size
		let spaceH = (self.view.frame.size.width - pageSize.width) / 2
		let spaceV = (self.view.frame.size.height - pageSize.height) / 2
		
		let toX = spaceH + (pageSize.width + 7) * multiplier
		if newAttached {
			var fromX: CGFloat
			if self.currentPos > self.oldPosition {
				if multiplier > 0 {
					fromX = spaceH + (pageSize.width + 7) * 2
				}else{
					fromX = spaceH + (pageSize.width + 7) * -2
				}
			}else if self.currentPos < self.oldPosition{
				if multiplier > 0 {
					fromX = spaceH + (pageSize.width + 7) * 2
				}else{
					fromX = spaceH + (pageSize.width + 7) * -2
				}
				
			}else {
				skipAnimation = true
				fromX = toX
			}
			vc.view.frame = CGRect(x: fromX, y: spaceV, width: pageSize.width , height: pageSize.height)
		}
		
		if !skipAnimation, animation {
			UIView.animate(withDuration: animationSpeed, animations: {
				vc.view.frame = CGRect(x: toX, y: spaceV, width: pageSize.width , height: pageSize.height)
			}, completion: nil)
		}else{
			vc.view.frame = CGRect(x: toX, y: spaceV, width: pageSize.width , height: pageSize.height)
		}
	}
	
	private func remove(viewController vc: UIViewController, multiplier: CGFloat, animation: Bool = true){
		if animation {
			let pageSize = vc.view.frame.size
			let spaceH = (self.view.frame.size.width - pageSize.width) / 2
			let spaceV = (self.view.frame.size.height - pageSize.height) / 2
			let originX = spaceH + (pageSize.width + 7) * multiplier
			
			UIView.animate(withDuration: animationSpeed, animations: {
				vc.view.frame = CGRect(x: originX, y: spaceV, width: pageSize.width , height: pageSize.height)
			}) { _ in
				vc.willMove(toParentViewController: nil)
				vc.view.removeFromSuperview()
				vc.removeFromParentViewController()
			}
		}else{
			vc.willMove(toParentViewController: nil)
			vc.view.removeFromSuperview()
			vc.removeFromParentViewController()
		}
	}
	
	fileprivate func buildPrevController(){
		guard let dataSource = self.dataSource else {
			return
		}
		
		if self.currentPos == 0 {
			if infiniteMode {
				let row = self.count - 1
				let vc = dataSource.pageControl(self, cellAtRow: row)
				let size = dataSource.pageControl?(self, sizeAtRow: row) ?? self.view.bounds.size
				let spaceV = (self.view.frame.size.height - size.height) / 2
				vc.view.frame = CGRect(x: -self.view.bounds.width, y: spaceV, width: size.width, height: size.height)
				self.currentPage[.prev] = vc
			}else{
				self.currentPage[.prev] = nil
			}
		}else{
			let row = self.currentPos - 1
			let vc = dataSource.pageControl(self, cellAtRow: row)
			let size = dataSource.pageControl?(self, sizeAtRow: row) ?? self.view.bounds.size
			let spaceV = (self.view.frame.size.height - size.height) / 2
			vc.view.frame = CGRect(x: -self.view.bounds.width, y: spaceV, width: size.width, height: size.height)
			
			self.currentPage[.prev] = vc
		}
	}
	
	fileprivate func buildNextController(){
		guard let dataSource = self.dataSource else {
			return
		}
		
		if self.currentPos == self.count - 1 {
			if infiniteMode {
				let vc = dataSource.pageControl(self, cellAtRow: 0)
				let size = dataSource.pageControl?(self, sizeAtRow: 0) ?? self.view.bounds.size
				let spaceV = (self.view.frame.size.height - size.height) / 2
				vc.view.frame = CGRect(x: self.view.bounds.width, y: spaceV, width: size.width, height: size.height)
				self.currentPage[.next] = vc
			}else{
				self.currentPage[.next] = nil
			}
		}else{
			let row = self.currentPos + 1
			let vc = dataSource.pageControl(self, cellAtRow: row)
			let size = dataSource.pageControl?(self, sizeAtRow: row) ?? self.view.bounds.size
			let spaceV = (self.view.frame.size.height - size.height) / 2
			vc.view.frame = CGRect(x: self.view.bounds.width, y: spaceV, width: size.width, height: size.height)
			self.currentPage[.next] = vc
		}
	}
	
	fileprivate func flowToLeft(){
		if (self.oldPosition - self.currentPos) == 1 {
			if let page = currentPage[.next], let viewController = page {
				remove(viewController: viewController, multiplier: 2, animation: true)
			}
			currentPage[.next] = currentPage[.current]
			currentPage[.current] = currentPage[.prev]
			currentPage[.prev] = nil
		}else{
			if let page = currentPage[.next], let viewController = page {
				remove(viewController: viewController, multiplier: 2, animation: true)
			}
			if let page = currentPage[.current], let viewController = page {
				remove(viewController: viewController, multiplier: 2, animation: true)
			}
			if let page = currentPage[.prev], let viewController = page {
				remove(viewController: viewController, multiplier: -2, animation: true)
			}
			
			currentPage[.next] = nil
			currentPage[.current] = nil
			currentPage[.prev] = nil
		}
	}
	
	fileprivate func flowToRight(){
		if (self.currentPos - self.oldPosition) == 1 {
			if let page = currentPage[.prev], let viewController = page {
				remove(viewController: viewController, multiplier: -2, animation: true)
			}
			currentPage[.prev] = currentPage[.current]
			currentPage[.current] = currentPage[.next]
			currentPage[.next] = nil
		}else{
			if let page = currentPage[.prev], let viewController = page {
				remove(viewController: viewController, multiplier: -2, animation: true)
			}
			if let page = currentPage[.current], let viewController = page {
				remove(viewController: viewController, multiplier: -2, animation: true)
			}
			if let page = currentPage[.next], let viewController = page {
				remove(viewController: viewController, multiplier: 2, animation: true)
			}
			
			currentPage[.prev] = nil
			currentPage[.current] = nil
			currentPage[.next] = nil
		}
	}
	
    @objc fileprivate func slideToRightGestureRecognizer(_ gesture: UISwipeGestureRecognizer){
        previousPage()
    }
    
    @objc fileprivate func slideToLeftGestureRecognizer(_ gesture: UISwipeGestureRecognizer){
        nextPage()
    }
    
}


