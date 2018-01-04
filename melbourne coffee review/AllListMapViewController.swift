//
//  AllListMapViewController.swift
//  melbourne coffee review
//
//  Created by Zihao Wang on 22/12/17.
//  Copyright © 2017 Zihao Wang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AllListMapViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBAction func currentLocation(_ sender: Any) {
        self.mapView.showsUserLocation = true
        let span = MKCoordinateSpanMake(0.018, 0.018)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!), span: span)
        mapView.setRegion(region, animated: true)
    }
    
    
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    var coffeeshops = [CoffeeShop]()
    var realcoffeeshop:CoffeeShop?
    var places = [CoffeeShopMap]()

    //var aCoffee:CoffeeShopMap?
    let regionRadius: CLLocationDistance = 1000

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkLocationAuthorizationStatus()
        self.mapView.showsUserLocation = true

      //  centerMapOnLocation(location:locationManager.location!)
        
      
//      let span = MKCoordinateSpanMake(0.018, 0.018)
//     let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude:(locationManager.location?.coordinate.latitude)!,longitude:(locationManager.location?.coordinate.longitude)!), span: span)
//     mapView.setRegion(region, animated: true)
        
        
        // Do any additional setup after loading the view.
    }
    
    func checkLocationAuthorizationStatus(){
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            self.locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
            
        }
        else
        {
            locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true

        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        
        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000)
                mapView.setRegion(viewRegion, animated: false)
            }
        }
    }
    
    func centerMapOnLocation(location:CLLocation){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        self.mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkLocationAuthorizationStatus()
        
        if coffeeshops.count != 0
        {
            mapView.removeAnnotations(mapView.annotations)
            
            for theCoffeeShop in coffeeshops{
                let lat = Double(theCoffeeShop.latitude!)
                let lon = Double(theCoffeeShop.longitude!)
                let name = theCoffeeShop.name ?? "No Name"
                let id = theCoffeeShop.id
                let thumb = theCoffeeShop.thumbPath
                let place = CoffeeShopMap(title: name , locationAddress: theCoffeeShop.street!, coordinate: CLLocationCoordinate2D(latitude:lat!,longitude:lon!),id:id!,thumb:thumb!)
                places.append(place)
                
            }
            mapView.addAnnotations(places)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "gotodetail"
        {
            let controller:CoffeeShopDetailViewController = segue.destination as! CoffeeShopDetailViewController
           
            controller.coffeeShop = self.realcoffeeshop

        }
    }
    

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? CoffeeShopMap{
        let identifier = "pin"
        var view:MKPinAnnotationView
        if let dequeuedview = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView{
            dequeuedview.annotation = annotation
            view = dequeuedview
            
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            let leftIconView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 53, height: 53))
            leftIconView.af_setImage(withURL: URL(string: "http://melbournecoffeereview.com/hotshots\(annotation.thumb)")!)
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            view.leftCalloutAccessoryView = leftIconView
        }
        return view
        }
      
        return nil
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
            
            performSegue(withIdentifier: "gotodetail", sender: self)
        }
    }
}
