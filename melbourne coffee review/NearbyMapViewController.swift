//
//  NearbyMapViewController.swift
//  melbourne coffee review
//
//  Created by Zihao Wang on 23/12/17.
//  Copyright © 2017 Zihao Wang. All rights reserved.
//

import UIKit
import MapKit
import AlamofireImage
import Alamofire
import Reachability
class NearbyMapViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var mapview: MKMapView!
    private var locationManager: CLLocationManager!
    
    @IBAction func currentLocation(_ sender: Any) {
        self.mapview.showsUserLocation = true
        let span = MKCoordinateSpanMake(0.018, 0.018)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!), span: span)
        mapview.setRegion(region, animated: true)
    }
    let reachability = Reachability()!
    private var currentLocation: CLLocation?
    var coffeeshops = [CoffeeShop]()
    var places = [CoffeeShopMap]()
    var realcoffeeshop:CoffeeShop?
    //var aCoffee:CoffeeShopMap?
    let regionRadius: CLLocationDistance = 1000
    var coffeeInFive = [CoffeeShop]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
        case .cellular:
            print("Reachable via Cellular")
        case .none:
            print("Network not reachable")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        mapview.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkLocationAuthorizationStatus()
        // Do any additional setup after loading the view.
       // fetchdata()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //checkLocationAuthorizationStatus()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .reachabilityChanged, object: reachability)
        
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
       

    }
 
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func fetchdata()
    {
        let  jsonUrlCoffeeShop = "http://hotshots.melbournecoffeereview.com/ServiceJeremy.php"
//        let  jsonUrlImage = "http://hotshots.melbournecoffeereview.com/imageservice.php"
//        
        guard let urlCoffee = URL(string: jsonUrlCoffeeShop) else
        {return}
        
//        guard let urlCoffeeImage = URL(string: jsonUrlImage) else
//       {return}
        
        URLSession.shared.dataTask(with: urlCoffee) { (data, response, err) in
            guard let data = data else {return}
            //            let dataAsString = String(data: data, encoding: .utf8)
            //            print(dataAsString!)
            do {
                self.coffeeshops = try JSONDecoder().decode([CoffeeShop].self, from: data)
                
                for coffeeshop in self.coffeeshops{
                    
                    //let currentLocation = self.appDelegate.currentLocation
                    let currentLocation = self.locationManager.location
                    let lat = Double(coffeeshop.latitude!)
                    let lon = Double(coffeeshop.longitude!)
                    let initLocation = CLLocation(latitude:lat!, longitude:lon!)

                    let distance = currentLocation?.distance(from: initLocation)
                    let doubleDis : Double = distance!
                    let intDis : Int = Int(doubleDis)
                    //print("\(intDis/1000) km")
                    if (intDis/1000) < 5{
                        self.coffeeInFive.append(coffeeshop)
                        //print(self.coffeeInFive)

                    }
                 }
            }
            catch let jsonErr{
                print(jsonErr)
            }
            
            
            
            DispatchQueue.main.async(execute: {
                if self.coffeeInFive.count != 0
                {
                    self.mapview.removeAnnotations(self.mapview.annotations)
                    
                    for theCoffeeShop in self.coffeeInFive{
                        let lat = Double(theCoffeeShop.latitude!)
                        let lon = Double(theCoffeeShop.longitude!)
                        let name = theCoffeeShop.name ?? "No Name"
                        let id = theCoffeeShop.id
                        let thumb = theCoffeeShop.thumbPath
                        let place = CoffeeShopMap(title: name , locationAddress: theCoffeeShop.street!, coordinate: CLLocationCoordinate2D(latitude:lat!,longitude:lon!),id:id!,thumb:thumb!)
                        self.places.append(place)
                        
                    }
                    self.mapview.addAnnotations(self.places)
                }
            })
            // print(self.coffeeshops)
            }.resume()
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func checkLocationAuthorizationStatus(){
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            self.locationManager.startUpdatingLocation()
            mapview.showsUserLocation = true
            
        }
        else
        {
            locationManager.requestWhenInUseAuthorization()
            //self.locationManager.startUpdatingLocation()
          //  checkLocationAuthorizationStatus()
           // self.alertBn(title: "Location Required", message: "Please change the location authorization in Setting")
        }
    }
    
    @objc func checkLocationAuthorizationStatusWhenRevoke(){
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            self.locationManager.startUpdatingLocation()
            mapview.showsUserLocation = true
            
        }
        else
        {
          //  locationManager.requestWhenInUseAuthorization()
            //self.locationManager.startUpdatingLocation()
            //  checkLocationAuthorizationStatus()
             self.alertBn(title: "Location Required", message: "Please change the location authorization in Setting")
        }
    }
   
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("NotDetermined")
            
        case .restricted:
            print("Restricted")
        case .denied:
            print("Denied")
            self.alertBn(title: "Location Required", message: "Please change the location authorization in Setting")
        
            NotificationCenter.default.addObserver(self, selector:#selector(self.checkLocationAuthorizationStatusWhenRevoke), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        case .authorizedAlways:
            print("AuthorizedAlways")
            locationManager!.startUpdatingLocation()
            mapview.showsUserLocation = true
        case .authorizedWhenInUse:
            print("AuthorizedWhenInUse")
            locationManager!.startUpdatingLocation()
            mapview.showsUserLocation = true
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        
        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000)
                mapview.setRegion(viewRegion, animated: false)
                fetchdata()
                
                
            }
        }
    }

override func viewDidAppear(_ animated: Bool) {
    super.viewDidLoad()
    //fetchdata()
    
}

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "nearbylist" {
            let controller  = segue.destination as! NearbyTableViewController
                controller.coffeeInFive = self.coffeeInFive
            
        }
        if segue.identifier == "gotodetailN"
        {
            let controller:CoffeeShopDetailViewController = segue.destination as! CoffeeShopDetailViewController
            
            controller.coffeeShop = self.realcoffeeshop
            
        }
    }
    

}
extension NearbyMapViewController:MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
       
        guard let annotation = annotation as? CoffeeShopMap else {return nil}
        let identifier = "nearby"
        var view:MKPinAnnotationView
        if let dequeuedview = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView{
            dequeuedview.annotation = annotation
            view = dequeuedview
            
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            
//            let strURL1:String = "https://www.planwallpaper.com/static/images/9-credit-1.jpg"
//            Alamofire.request(strURL1).responseData(completionHandler: { response in
//                debugPrint(response)
//
//                debugPrint(response.result)
//
//                if let image1 = response.result.value {
//                    let image = UIImage(data: image1)
//                    let size = CGSize(width: 50, height: 50)
//                    view.image = image?.af_imageAspectScaled(toFit: size)
//
//                }
//            })
            let leftIconView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 53, height: 53))
            leftIconView.af_setImage(withURL: URL(string: "http://melbournecoffeereview.com/hotshots\(annotation.thumb)")!)
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            view.leftCalloutAccessoryView = leftIconView
            
        }
        return view
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("tap")
        let location = view.annotation as! CoffeeShopMap
        //        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        //        location.mapItem().openInMaps(launchOptions: launchOptions
        //        )
        
        if control == view.rightCalloutAccessoryView{
            
            for thecoffeeshop in coffeeshops{
                if thecoffeeshop.id == location.id{
                    self.realcoffeeshop = thecoffeeshop
                }
            }
            performSegue(withIdentifier: "gotodetailN", sender: self)
        }
    }
    
}
