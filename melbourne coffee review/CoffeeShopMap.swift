//
//  CoffeeShopMap.swift
//  melbourne coffee review
//
//  Created by Zihao Wang on 22/12/17.
//  Copyright © 2017 Zihao Wang. All rights reserved.
//

import Foundation
import MapKit
import Contacts

class CoffeeShopMap:NSObject,MKAnnotation{
    let coordinate: CLLocationCoordinate2D
    let title:String?
    let locationAddress:String
    let id:String
    let thumb:String
    
    init(title:String,locationAddress:String,coordinate:CLLocationCoordinate2D,id:String,thumb:String) {
        self.title = title 
        self.locationAddress = locationAddress
        self.coordinate = coordinate
        self.id  = id
        self.thumb = thumb
        super.init()
    }
    var subtitle: String?{
        return locationAddress
    }
    
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey:subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark:placemark)
        mapItem.name = title
        return mapItem
    }
    
}
