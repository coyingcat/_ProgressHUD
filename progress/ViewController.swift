//
//  ViewController.swift
//  progress
//
//  Created by Jz D on 2021/3/9.
//

import UIKit

class ViewController: UIViewController {


    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        
    }

    @IBAction func comeOne(_ sender: Any) {
        let hud = ProgressHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            hud?.hide()
        }
    
        
    }
    
    
    
    @IBAction func cometwo(_ sender: Any) {
        
        
        ProgressHUD.show("辩护人，好看")
        
        
    }
    
    
    
}

