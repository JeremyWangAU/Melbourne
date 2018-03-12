//
//  SettingViewController.swift
//  melbourne coffee review
//
//  Created by Zihao Wang on 23/12/17.
//  Copyright © 2017 Zihao Wang. All rights reserved.
//

import UIKit
import MessageUI

class SettingViewController: UIViewController, UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate {
    @IBOutlet weak var tableview: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableview.dequeueReusableCell(withIdentifier: "EmailCell", for: indexPath)
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableview.dequeueReusableCell(withIdentifier: "TwitterCell", for: indexPath)
            return cell
        }
        else if indexPath.section == 2 {
            let cell = tableview.dequeueReusableCell(withIdentifier: "FacebookCell", for: indexPath)
            return cell
        }
        else if indexPath.section == 3 {
            let cell = tableview.dequeueReusableCell(withIdentifier: "RecommendCell", for: indexPath)
            return cell
        }
        else
        {
        let cell = tableview.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            if MFMailComposeViewController.canSendMail(){
                let controller = MFMailComposeViewController()
                controller.mailComposeDelegate = self
                controller.setToRecipients(["<webmaster@melbournecoffeereview.com>"])
                self.present(controller, animated: true, completion: nil)
            }
            else{
                self.showSendMailErrorAlert()
            }
        }
        else if indexPath.section == 1 {
            let twUrl = URL(string: "twitter://user?screen_name=mcreview")!
            let twUrlWeb = URL(string: "https://www.twitter.com/mcreview")!
            if UIApplication.shared.canOpenURL(twUrl){
                UIApplication.shared.openURL(twUrl)
            }else{
                UIApplication.shared.openURL(twUrlWeb)
            }
        }
        else if indexPath.section == 2 {
            let facebookUrl = URL(string: "fb://profile/150848451601470")!
            let facebookWeb = URL(string: "https://www.facebook.com/mcreview")!
            if UIApplication.shared.canOpenURL(facebookUrl){
                UIApplication.shared.openURL(facebookUrl)
            }else{
                UIApplication.shared.openURL(facebookWeb)
            }
        }
        else if indexPath.section == 3 {
            let RecommendWeb = "http://hotshots.melbournecoffeereview.com/coffeeRecommend/recommend"
            if let url = URL(string: RecommendWeb) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:],
                                              completionHandler: {
                                                (success) in
                    })
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.delegate = self
        self.tableview.dataSource = self
        

        // Do any additional setup after loading the view.
    }
    func showSendMailErrorAlert() {
        
        let sendMailErrorAlert = UIAlertController(title: "cannot send email", message: "You did not set up email account in your device，please send again after setting up.", preferredStyle: .alert)
        sendMailErrorAlert.addAction(UIAlertAction(title: "confirm", style: .default) { _ in })
        self.present(sendMailErrorAlert, animated: true){}
        
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("cancel")
        case MFMailComposeResult.sent.rawValue:
            print("success")
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
