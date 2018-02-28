//
//  ViewControllerExtension.swift
//  melbourne coffee review
//
//  Created by Zihao Wang on 4/1/18.
//  Copyright © 2018 Zihao Wang. All rights reserved.
//

import UIKit
import Reachability

extension UIViewController {
    
    func alertBn(title:String,message:String){
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    // Create OK button
    let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
    
    // Code in this block will trigger when OK button tapped.
    print("Ok button tapped");
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            } else {
                    let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
                    if let url = settingsUrl {
                        UIApplication.shared.openURL(url as URL)
                   }
                // Fallback on earlier version
                
           }
        }
        
    
        }
    alertController.addAction(OKAction)
    self.present(alertController, animated: true, completion:nil)
    }
}
