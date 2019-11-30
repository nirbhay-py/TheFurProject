//
//  mapVC.swift
//  TheFurProject
//
//  Created by Nirbhay Singh on 24/11/19.
//  Copyright © 2019 Nirbhay Singh. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import JGProgressHUD
import CoreLocation
import SCLAlertView

class mapVC: UIViewController,CLLocationManagerDelegate{
    let locationManager = CLLocationManager()
    let hud = JGProgressHUD.init()
    var geocodeRes:String!
    var thisUser:UserClass!
    var userCoordinate:CLLocationCoordinate2D!
    var mapView:GMSMapView?
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLocation()
        nameLbl.text = "Hi "+thisUser.givenName
        
    }
    func setUpLocation(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        hud.show(in: self.view,animated: true)
        locationManager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("called")
        let location:CLLocation = locations[0]
        let coordinate:CLLocationCoordinate2D = location.coordinate
        self.userCoordinate = coordinate
        locationManager.stopUpdatingLocation()
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate, completionHandler:{(resp,error)  in
            self.hud.dismiss()
            if(error != nil || resp==nil ){
                showAlert(msg: "You may have connectivity issues :"+error!.localizedDescription)
            }else{
                self.geocodeRes = resp?.results()?.first?.thoroughfare
                self.addressLbl.text = self.geocodeRes
                print(resp?.results()?.first as Any)
            }
            
        })
        drawMap()
    }
    func drawMap(){
        let camera = GMSCameraPosition.camera(withLatitude: self.userCoordinate.latitude, longitude: self.userCoordinate.longitude, zoom: 17)
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height-250),camera: camera)
        do {
            mapView!.mapStyle = try GMSMapStyle(jsonString: mapStyle)
        } catch {
          NSLog("One or more of the map styles failed to load. \(error)")
        }
        self.view.addSubview(mapView!)
        populateMap()
    }
    
    func populateMap(){
        let ref = Database.database().reference().child("reports-node")
        _ = ref.observe(DataEventType.value, with: { (snapshot) in
            let reports = snapshot.value as! [String:AnyObject]
            for report in reports{
                print(report)
                let lat = report.value["location-lat"] as! Double
                let lon = report.value["location-lon"] as! Double
                let coordinates = CLLocationCoordinate2D(latitude:lat,longitude:lon)
                let complainee = report.value["given-name"] as! String
                let details = report.value["desc"] as! String
                let type = report.value["report-type"] as! String
                let userID = report.value["user-id"] as! String
                let email = report.value["email"] as! String
                let fullName = report.value["full-name"] as! String

            }
        })
    }
    
//    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
//     return false
//     }
//    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
//        return self.customMarker
//    }
    
    
    
    
    
    
    
    @IBAction func infoBoxShow(_ sender: Any) {
        let box = SCLAlertView()
        box.showInfo("We're here to help", subTitle: "Here's how the app works. You or anyone else can raise issues they see. Others can upvote these issues and get in touch with the person who raised to issue to help resolve it. Cheers!")
    }
    
    
    
    

}
