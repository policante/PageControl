//
//  ViewController.swift
//  PageControl
//
//  Created by Rodrigo Martins on 09/06/2017.
//  Copyright (c) 2017 Rodrigo Martins. All rights reserved.
//

import UIKit
import PageControl

class MyUser {
    
    var id: Int?
    var name: String?
    var email: String?
    var following: Int = 0
    var followers: Int = 0
    var boy: Bool = false
    
    init(id: Int, name: String, email: String, following: Int, followers: Int, boy: Bool) {
        self.id = id
        self.name = name
        self.email = email
        self.following = following
        self.followers = followers
        self.boy = boy
    }
}

class ViewController: UIViewController {

    var pageController: PageControlViewController!
    var data: [MyUser] = []
    var dataController: [UIViewController] = []
    
    @IBOutlet weak var containerView: UIView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.data = [
            MyUser(id: 1, name: "Rodrigo Martins", email: "policante.martins@gmail.com", following: 1000, followers: 2000, boy: true),
            MyUser(id: 2, name: "Michael Roy", email: "michael.roy@mail.com", following: 31, followers: 501, boy: true),
            MyUser(id: 3, name: "Frank Donald", email: "frank.donald@mail.com", following: 154, followers: 921, boy: true),
            MyUser(id: 4, name: "Tom", email: "tom@mail.com", following: 12, followers: 65, boy: true),
            MyUser(id: 5, name: "Jerry", email: "jerry@mail.com", following: 720, followers: 682, boy: false),
            MyUser(id: 6, name: "Piterson", email: "piterson@mail.com", following: 605, followers: 240, boy: true),
            MyUser(id: 7, name: "Kessy", email: "kessy@mail.com", following: 120, followers: 804, boy: false),
            MyUser(id: 8, name: "Juh", email: "juh@mail.com", following: 942, followers: 2510, boy: false)
        ]
        
        for us in self.data {
            let vc = CardItemViewController()
            vc.user = us
            vc.delegate = self
            self.dataController.append(vc)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? PageControlViewController {
            self.pageController = controller
            self.pageController.delegate = self
            self.pageController.dataSource = self
        }
    }
	
	@IBAction func randomPageTap(){
		let index = random(0..<self.pageController.count)
		self.pageController.currentPosition = index
	}

	func random(_ range:Range<Int>) -> Int {
		return range.lowerBound + Int(arc4random_uniform(UInt32(range.upperBound - range.lowerBound)))
	}
	
}

extension ViewController: CardDelegate {
    
    func removeCard(_ user: MyUser) {
        for position in 0..<self.data.count {
            let dataUser = self.data[position]
            if dataUser.id == user.id {
                self.data.remove(at: position)
                self.dataController.remove(at: position)
                break
            }
        }
        self.pageController.updateData()
    }
    
}

extension ViewController: PageControlDelegate {
    
    func pageControl(_ pageController: PageControlViewController, atSelected viewController: UIViewController) {
        (viewController as! CardItemViewController).animateImage()
    }
    
    func pageControl(_ pageController: PageControlViewController, atUnselected viewController: UIViewController) {
        
    }
    
}

extension ViewController: PageControlDataSource {
    
    func numberOfCells(in pageController: PageControlViewController) -> Int {
        return self.dataController.count
    }
    
    func pageControl(_ pageController: PageControlViewController, cellAtRow row: Int) -> UIViewController! {
        return self.dataController[row]
    }
    
    func pageControl(_ pageController: PageControlViewController, sizeAtRow row: Int) -> CGSize {
        let width = pageController.view.bounds.size.width - 20
        if row == pageController.currentPosition {
            return CGSize(width: width, height: 500)
        }
        return CGSize(width: width, height: 500)
    }
    
}
