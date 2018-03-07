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
    
}


class AllListTableViewController: UITableViewController,FloatRatingViewDelegate {
    let reachability = Reachability()!

    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
        
    }
    
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

        fetchdata()
        
//        self.tableView.delegate = self
//        self.tableView.dataSource = self
       // let jsonUrlString ="M3lb0urn3c0ff33"
//        let  jsonUrlCoffeeShop = "http://hotshots.melbournecoffeereview.com/ServiceJeremy.php"
//        let  jsonUrlImage = "http://hotshots.melbournecoffeereview.com/imageservice.php"
//
//        guard let urlCoffee = URL(string: jsonUrlCoffeeShop) else
//        {return}
//
//        guard let urlCoffeeImage = URL(string: jsonUrlImage) else
//        {return}
//
//        URLSession.shared.dataTask(with: urlCoffee) { (data, response, err) in
//           guard let data = data else {return}
////            let dataAsString = String(data: data, encoding: .utf8)
////            print(dataAsString!)
//            do {
//                 self.coffeeshops = try JSONDecoder().decode([CoffeeShop].self, from: data)
//
//            }
//            catch let jsonErr{
//                print(jsonErr)
//            }
//            DispatchQueue.main.async(execute: {self.tableView.reloadData()})
//           // print(self.coffeeshops)
//            }.resume()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func searchBarIsEmpty() -> Bool{
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText:String, scope:String = "ALL") {
        filterCoffeesshops = coffeeshops.filter({(coffeeshop : CoffeeShop) -> Bool in
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
                
            }
            catch let jsonErr{
                print(jsonErr)
            }
            DispatchQueue.main.async(execute: {self.tableView.reloadData()})
             print(self.coffeeshops)
            }.resume()
    
    
    
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
        return self.coffeeshops.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllListTableViewCell", for: indexPath) as! AllListTableViewCell
        let coffeeshop:CoffeeShop
        if isFiltering(){
            coffeeshop = filterCoffeesshops[indexPath.row]
        } else{
             coffeeshop = self.coffeeshops[indexPath.row]

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
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showmap" {
            let controller  = segue.destination as! AllListMapViewController
            controller.coffeeshops = self.coffeeshops
        }
        
        if segue.identifier == "alldetail"{
            if let indexPath = tableView.indexPathForSelectedRow{
                let controller = segue.destination as! CoffeeShopDetailViewController
                if isFiltering(){
                    controller.coffeeShop = self.filterCoffeesshops[indexPath.row]
                }
                else{
                controller.coffeeShop = self.coffeeshops[indexPath.row]
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
