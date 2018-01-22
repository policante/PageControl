//
//  CardItemViewController.swift
//  PageControl
//
//  Created by Rodrigo Martins on 08/09/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

protocol CardDelegate {
    func removeCard(_ user: MyUser)
}

class CardItemViewController: UIViewController {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var btnRemove: UIButton!
    
    var user: MyUser!
    var delegate: CardDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        name.text = user.name!
        email.text = user.email!
        following.text = "\(user.following)"
        followers.text = "\(user.followers)"
        photo.image = user.boy ? #imageLiteral(resourceName: "boy") : #imageLiteral(resourceName: "girl")
        
        photo.layer.cornerRadius = photo.frame.size.height / 2
        btnRemove.layer.cornerRadius = btnRemove.frame.size.height / 2
    }
	
    func animateImage(){
        guard self.photo != nil else {
            return
        }
        UIView.transition(with: self.photo, duration: 1.0, options: .transitionFlipFromLeft, animations: nil)
    }
    
    @IBAction func doRemove(_ sender: Any) {
        self.delegate.removeCard(self.user)
    }
    
}
