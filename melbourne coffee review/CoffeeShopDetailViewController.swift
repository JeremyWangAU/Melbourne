//
//  CoffeeShopDetailViewController.swift
//  melbourne coffee review
//
//  Created by Zihao Wang on 25/12/17.
//  Copyright © 2017 Zihao Wang. All rights reserved.
//

import UIKit
import AlamofireImage
import ImageSlideshow
import MapKit
struct ImageUrl:Decodable {
    let filePath:String?
}

class CoffeeShopDetailViewController: UIViewController {
    
    @IBOutlet weak var slideshow: ImageSlideshow!
    
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var addressL: UILabel!
    @IBOutlet weak var phoneL: UILabel!
    @IBOutlet weak var websiteL: UILabel!
    
    
    @IBOutlet weak var reviewText: UITextView!
    var coffeeShop:CoffeeShop?

    @IBAction func navigation(_ sender: Any) {
        let lat = Double(coffeeShop!.latitude!)
        let lon = Double(coffeeShop!.longitude!)
        let desLocation = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
        openMapsAppWithDirections(to: desLocation, destinationName: (coffeeShop?.street)!)
    }
    
    
    var coffeeImages = [ImageUrl]()
    var alamofireSource = [AlamofireSource]()
    
    func openMapsAppWithDirections(to coordinate: CLLocationCoordinate2D, destinationName name: String) {
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name // Provide the name of the destination in the To: field
        mapItem.openInMaps(launchOptions: options)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let  jsonUrlImage = "http://hotshots.melbournecoffeereview.com/imageservice.php?shopId=\(self.coffeeShop!.id ?? "0")"
        guard let urlCoffeeImage = URL(string: jsonUrlImage) else {return}
        URLSession.shared.dataTask(with: urlCoffeeImage) { (data, reponse, err) in
            guard let data = data else {return}
            do {
                self.coffeeImages = try JSONDecoder().decode([ImageUrl].self, from: data)
            }
            catch let jsonErr{
                print(jsonErr)
            }
            
            
            for coffeeimage in self.coffeeImages
            {
                let URL_IMAGE = URL(string: "http://melbournecoffeereview.com/hotshots\(coffeeimage.filePath!)")!
                self.alamofireSource.append(AlamofireSource(url: URL_IMAGE))
            }
            
            DispatchQueue.main.async(execute: {            self.slideshow.setImageInputs(self.alamofireSource)
                
            })

            print(self.alamofireSource)
        }.resume()
        
        
        slideshow.backgroundColor = UIColor.white
        slideshow.pageControlPosition = PageControlPosition.underScrollView
        slideshow.pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        slideshow.pageControl.pageIndicatorTintColor = UIColor.black
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFill
        slideshow.slideshowInterval = 0
        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        slideshow.activityIndicator = DefaultActivityIndicator()
        slideshow.currentPageChanged = { page in
            print("current page:", page)
        }
        
        // can be used with other sample sources as `afNetworkingSource`, `alamofireSource` or `sdWebImageSource` or `kingfisherSource`
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(CoffeeShopDetailViewController.didTap))
        slideshow.addGestureRecognizer(recognizer)
        self.nameL.text = self.coffeeShop?.name
        
        self.addressL.text = (self.coffeeShop?.street)! + " " + (self.coffeeShop?.suburb)!
        self.websiteL.text = self.coffeeShop?.website
        self.reviewText.text = self.coffeeShop?.review
    }
    
    @objc func didTap() {
        let fullScreenController = slideshow.presentFullScreenController(from: self)
        // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
        // Do any additional setup after loading the view.

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
