//
//  PageControl.swift
//  PageControl
//
//  Created by Rodrigo Martins on 09/06/2017.
//  Copyright (c) 2017 Rodrigo Martins. All rights reserved.
//
import UIKit

public protocol PageControlDelegate {
    
    func pageControl(_ pageController: PageControlViewController, atSelected viewController: UIViewController)
    
    func pageControl(_ pageController: PageControlViewController, atUnselected viewController: UIViewController)
}

@objc public protocol PageControlDataSource {
    
    @objc optional func pageControl(_ pageController: PageControlViewController, sizeAtRow row: Int) -> CGSize
    
    func numberOfCells(in pageController: PageControlViewController) -> Int
    
    func pageControl(_ pageController: PageControlViewController, cellAtRow row: Int) -> UIViewController!
    
}

public class PageControlViewController: UIViewController, UICollectionViewDelegate {
    
    open var delegate: PageControlDelegate? = nil
    open var dataSource: PageControlDataSource? = nil
    
    open var animation: UIViewAnimationCurve = .easeInOut
    open var animationSpeed: TimeInterval = 0.18
    
    fileprivate var data: [Int: UIViewController]?
    fileprivate var currentPos : Int = 0
    fileprivate var currentPage: UIViewController?
	
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
			if let dataSource = self.dataSource {
				if newValue >= 0 , newValue < self.count {
					currentPos = newValue
					if let page = dataSource.pageControl(self, cellAtRow: currentPos) {
						self.setPage(page)
						UIView.animate(withDuration: self.animationSpeed, animations: {
							self.setupViews(currentPosition: self.currentPos)
						}, completion: { finished in
						})
					}
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
    }
    
    fileprivate func setPage(_ newPage: UIViewController?){
        if let page = currentPage {
            self.delegate?.pageControl(self, atUnselected: page)
        }
        
        self.currentPage = newPage
        self.data?[self.currentPos] = newPage
        
        if let page = currentPage {
            self.delegate?.pageControl(self, atSelected: page)
        }
        
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.data = [:]
        self.currentPos = 0
        updateData()
    }
    
    open func updateData(){
        for (_, page) in self.data! {
            page.willMove(toParentViewController: nil)
            page.view.removeFromSuperview()
            page.removeFromParentViewController()
        }
        
        self.data?.removeAll()
        for position in 0..<self.count {
            if let dataSource = self.dataSource {
                self.data![position] = dataSource.pageControl(self, cellAtRow: position)
            }
        }
        if self.currentPos >= self.data!.count {
            self.currentPos = self.data!.count - 1
        }
        
        if self.currentPos <= 0 {
            self.currentPos = 0
        }
        
        self.setPage(self.data?[self.currentPos])
        self.setupViews(currentPosition: self.currentPos)
        
        for (_, page) in self.data! {
            self.addChildViewController(page)
            self.view.addSubview(page.view)
            page.didMove(toParentViewController: self)
        }
    }
    
    open func nextPage(){
        if let dataSource = self.dataSource {
            if (currentPos + 1) < self.count {
                currentPos += 1
                if let page = dataSource.pageControl(self, cellAtRow: currentPos) {
                    self.setPage(page)
                    UIView.animate(withDuration: self.animationSpeed, animations: {
                        self.setupViews(currentPosition: self.currentPos)
                    }, completion: { finished in
                    })
                }
            }
        }
    }
    
    open func previousPage(){
        if let dataSource = self.dataSource {
            if (currentPos - 1) >= 0 {
                currentPos -= 1
                if let page = dataSource.pageControl(self, cellAtRow: self.currentPos) {
                    self.setPage(page)
                    UIView.animate(withDuration: self.animationSpeed, animations: {
                        self.setupViews(currentPosition: self.currentPos)
                    }, completion: { finished in
                    })
                }
            }
        }
    }
    
    fileprivate func setupViews(currentPosition atPosition: Int){
        for position in 0..<self.count {
            var pageSize = self.view.bounds.size
            if let size = self.dataSource?.pageControl?(self, sizeAtRow: position) {
                pageSize = size
            }
            
            let spaceH = (self.view.frame.size.width - pageSize.width) / 2
            let spaceV = (self.view.frame.size.height - pageSize.height) / 2
            
            let originX = spaceH + (pageSize.width + 7) * CGFloat(position - atPosition)
            self.data?[position]?.view.frame = CGRect(x: originX, y: spaceV, width: pageSize.width , height: pageSize.height)
        }
    }
    
    @objc fileprivate func slideToRightGestureRecognizer(_ gesture: UISwipeGestureRecognizer){
        previousPage()
    }
    
    @objc fileprivate func slideToLeftGestureRecognizer(_ gesture: UISwipeGestureRecognizer){
        nextPage()
    }
    
}
