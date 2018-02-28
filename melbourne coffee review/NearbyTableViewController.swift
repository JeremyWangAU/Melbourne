//
//  NearbyTableViewController.swift
//  melbourne coffee review
//
//  Created by Zihao Wang on 23/12/17.
//  Copyright © 2017 Zihao Wang. All rights reserved.
//

import UIKit
import AlamofireImage
import CoreLocation


class NearbyTableViewController: UITableViewController,FloatRatingViewDelegate {
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
        
    }
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var coffeeshops = [CoffeeShop]()
    var coffeeInFive = [CoffeeShop]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fetchdata()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func fetchdata()
    {
        let  jsonUrlCoffeeShop = "http://hotshots.melbournecoffeereview.com/ServiceJeremy.php"
//       let  jsonUrlImage = "http://hotshots.melbournecoffeereview.com//imageservice.php"
        
        guard let urlCoffee = URL(string: jsonUrlCoffeeShop) else
        {return}
        
        //guard let urlCoffeeImage = URL(string: jsonUrlImage) else
        //{return}
        
        URLSession.shared.dataTask(with: urlCoffee) { (data, response, err) in
            guard let data = data else {return}
            //            let dataAsString = String(data: data, encoding: .utf8)
            //            print(dataAsString!)
            do {
                self.coffeeshops = try JSONDecoder().decode([CoffeeShop].self, from: data)
                for coffeeshop in self.coffeeshops{
                    let currentLocation = self.appDelegate.currentLocation
                    let lat = Double(coffeeshop.latitude!)
                    let lon = Double(coffeeshop.longitude!)
                    let initLocation = CLLocation(latitude:lat!, longitude:lon!)
                    
                    let distance = currentLocation?.distance(from: initLocation)
                    let doubleDis : Double = distance!
                    let intDis : Int = Int(doubleDis)
                    print("\(intDis/1000) km")
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
                self.tableView.reloadData()})
            // print(self.coffeeshops)
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
        return self.coffeeInFive.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyCell", for: indexPath) as! NearbyTableViewCell
       // print(coffeeInFive)
        if coffeeInFive.count != 0{
        let  coffeeshop = self.coffeeInFive[indexPath.row]
        cell.nearbyAddress.text = coffeeshop.street
        cell.nearbyName.text = coffeeshop.name
        let URL_IMAGE = URL(string: "http://melbournecoffeereview.com/hotshots\(coffeeshop.thumbPath!)")!
        cell.nearbyImage.af_setImage(withURL: URL_IMAGE)
        
        
        cell.floatRatingView.fullImage = UIImage(named: "bean")
        cell.floatRatingView.emptyImage = UIImage(named: "bean")
        // Optional params
        cell.floatRatingView.delegate = self
        cell.floatRatingView.contentMode = UIViewContentMode.scaleAspectFill
        cell.floatRatingView.maxRating = 5
        cell.floatRatingView.minRating = 1
        //Set star rating
            cell.floatRatingView.rating =  Float(coffeeshop.beanRating!)!
        cell.floatRatingView.editable = false
//        let locValue:CLLocationCoordinate2D = (locationManager!.location?.coordinate)!
        
        }

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
        
//        if segue.identifier == "nearbymap" {
//            let controller  = segue.destination as! NearbyMapViewController
//            controller.coffeeshops = self.coffeeInFive
//        }
        if segue.identifier == "gotodetailNT"{
            if let indexPath = tableView.indexPathForSelectedRow{
            let controller = segue.destination as! CoffeeShopDetailViewController
            controller.coffeeShop = self.coffeeInFive[indexPath.row]
            }
        }
    }
    

}
