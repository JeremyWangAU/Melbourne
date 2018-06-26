//
//  AllListTableViewController.swift
//  melbourne coffee review
//
//  Created by Zihao Wang on 13/12/17.
//  Copyright © 2017 Zihao Wang. All rights reserved.
//

import UIKit
import AlamofireImage
import Reachability
import CoreLocation

struct CoffeeShop: Decodable {
    let id:String?
    let name:String?
    let street:String?
    let suburb:String?
    let state:String?
    let beanRating:String?
    let latitude:String?
    let longitude:String?
    let phone:String?
    let website:String?
    let ownerId:String?
    let coffeeBrand:String?
    let review:String?
    let thumbPath:String?
    
    func getDistance(currentLocation:CLLocation) -> Int {
        let lat = Double(self.latitude!)
        let lon = Double(self.longitude!)
        let initLocation = CLLocation(latitude:lat!, longitude:lon!)
        
        let distance = currentLocation.distance(from: initLocation)
        let doubleDis : Double = distance
        let intDis : Int = Int(doubleDis)
        return intDis
    }
    
}


class AllListTableViewController: UITableViewController,FloatRatingViewDelegate,CLLocationManagerDelegate {
    let reachability = Reachability()!
    private var currentCoordinate:CLLocationCoordinate2D?

    var currentLocation:CLLocation?

    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
        
    }
    
    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var locationManager: CLLocationManager!
    
    @IBOutlet weak var rightbutton: UIBarButtonItem!
    
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
    
    var coffeeshops = [CoffeeShop]()
    var nearCoffeeshops = [CoffeeShop]()
    var filterCoffeesshops = [CoffeeShop]()
    
    let searchController = UISearchController(searchResultsController:nil)
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkLocationAuthorizationStatus()
        searchController.searchResultsUpdater = self
       // searchController.searchBar.delegate = self
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        } else {
            // Fallback on earlier versions
        }
        searchController.searchBar.placeholder = "Search Coffess Shop by name and address"
      if #available(iOS 11.0, *) {
        navigationItem.searchController = searchController
     } else {
           tableView.tableHeaderView = searchController.searchBar
            // Fallback on earlier versions
       }
        definesPresentationContext = true

    }
    
    func searchBarIsEmpty() -> Bool{
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText:String, scope:String = "ALL") {
        filterCoffeesshops = nearCoffeeshops.filter({(coffeeshop : CoffeeShop) -> Bool in
            return coffeeshop.street!.lowercased().contains(searchText.lowercased())||coffeeshop.name!.lowercased().contains(searchText.lowercased())||coffeeshop.suburb!
                .lowercased().contains(searchText.lowercased())
        
        })
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool{
        return searchController.isActive && !searchBarIsEmpty() 
    }
    
    
    func fetchdata()
    {
        self.nearCoffeeshops.removeAll()
        let  jsonUrlCoffeeShop = "http://hotshots.melbournecoffeereview.com/ServiceJeremy.php"
        
        
        guard let urlCoffee = URL(string: jsonUrlCoffeeShop) else
        {return}
        
       // guard let urlCoffeeImage = URL(string: jsonUrlImage) else
       // {return}
        
        URLSession.shared.dataTask(with: urlCoffee) { (data, response, err) in
            guard let data = data else {return}
            //            let dataAsString = String(data: data, encoding: .utf8)
            //            print(dataAsString!)
            do {
                self.coffeeshops = try JSONDecoder().decode([CoffeeShop].self, from: data)
                for coffeeshop in self.coffeeshops{
                    
                    if (coffeeshop.getDistance(currentLocation: self.currentLocation!)/1000) < 5{
                        self.nearCoffeeshops.append(coffeeshop)
                        self.nearCoffeeshops.sort{
                            return $0.getDistance(currentLocation: self.currentLocation!) < $1.getDistance(currentLocation: self.currentLocation!)
                        }
                            
                        
                    }
                }
                
            }
            catch let jsonErr{
                print(jsonErr)
            }
            DispatchQueue.main.async(execute: {
              
                self.tableView.reloadData()})
            }.resume()
    
    
        
    }
    
    @objc func checkLocationAuthorizationStatus(){
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            self.locationManager.startUpdatingLocation()
            
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
        case .authorizedWhenInUse:
            print("AuthorizedWhenInUse")
            locationManager!.startUpdatingLocation()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        
        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                let locationValue:CLLocationCoordinate2D = manager.location!.coordinate
                       self.currentCoordinate = locationValue
                      self.currentLocation = CLLocation(latitude:(self.currentCoordinate?.latitude)!,longitude:(self.currentCoordinate?.longitude)!)
                
                fetchdata()
                
                
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isFiltering(){
            return filterCoffeesshops.count
        }
        return self.nearCoffeeshops.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllListTableViewCell", for: indexPath) as! AllListTableViewCell
        let coffeeshop:CoffeeShop
        if isFiltering(){
            coffeeshop = filterCoffeesshops[indexPath.row]
            
        } else{
            
             coffeeshop = self.nearCoffeeshops[indexPath.row]

        }
        cell.AllListName.text = coffeeshop.name
       // cell.AllListRating.text = coffeeshop.beanRating
        cell.AlllListAddress!.text = coffeeshop.street
        let URL_IMAGE = URL(string: "http://melbournecoffeereview.com/hotshots\(coffeeshop.thumbPath!)")!
        cell.AllListImage.af_setImage(withURL:URL_IMAGE)
        
        // Configure the cell...
        cell.floatRatingView.fullImage = UIImage(named: "bean")
        cell.floatRatingView.emptyImage = UIImage(named: "bean")
        // Optional params
        cell.floatRatingView.delegate = self
        cell.floatRatingView.contentMode = UIViewContentMode.scaleAspectFill
        cell.floatRatingView.maxRating = 5
        cell.floatRatingView.minRating = 1
        //Set star rating
        cell.floatRatingView.rating = Float(coffeeshop.beanRating!)!
        cell.floatRatingView.editable = false
        return cell
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "alldetail"{
            if let indexPath = tableView.indexPathForSelectedRow{
                let controller = segue.destination as! CoffeeShopDetailViewController
                if isFiltering(){
                    controller.coffeeShop = self.filterCoffeesshops[indexPath.row]
                }
                else{
                controller.coffeeShop = self.nearCoffeeshops[indexPath.row]
                }
            }
        }
    }
    

}
extension AllListTableViewController:UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
