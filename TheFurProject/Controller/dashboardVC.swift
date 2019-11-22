//
//  dashboardVC.swift
//  TheFurProject
//
//  Created by Nirbhay Singh on 22/11/19.
//  Copyright © 2019 Nirbhay Singh. All rights reserved.
//

import UIKit
import JGProgressHUD
import SPPermissions
import CoreLocation
import SCLAlertView
import GoogleMaps

class dashboardVC: UIViewController,CLLocationManagerDelegate{
    
    @IBOutlet weak var pastConst: NSLayoutConstraint!
    @IBOutlet weak var mapConst: NSLayoutConstraint!
    @IBOutlet weak var issueConst: NSLayoutConstraint!
    @IBOutlet weak var myIssues: UIButton!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var issueBtn: UIButton!
    @IBOutlet weak var mapBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    let hud = JGProgressHUD()

    var thisUser:UserClass!
    let locationManager = CLLocationManager()
    
    
    override func viewWillAppear(_ animated: Bool) {
        issueBtn.layer.cornerRadius = 15
        mapBtn.layer.cornerRadius = 15
        myIssues.layer.cornerRadius = 15
        let url = URL(string: thisUser.photoURL!)
        profileImage.load(url:url!)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        profileImage.layer.borderWidth = 5
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.systemYellow.cgColor
        profileImage.layer.cornerRadius = 30
        profileImage.clipsToBounds = true
        nameLbl.text = "Hi "+thisUser.givenName
        issueConst.constant -= view.bounds.width
        mapConst.constant -= view.bounds.width
        pastConst.constant -= view.bounds.width
        view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.7, animations: {
            self.issueConst.constant+=self.view.bounds.width
            self.pastConst.constant += self.view.bounds.width
            self.mapConst.constant += self.view.bounds.width
            self.view.layoutIfNeeded()
        })
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        askPermissions()
        setUpLocation()
    


}
    @IBAction func viewAccount(_ sender: Any) {
        SCLAlertView().showInfo("Your account", subTitle:"Name - "+thisUser.fullName+"\nEmail - "+thisUser.email)
    }
    
    
    func askPermissions(){
        let isAllowedCamera = SPPermission.isAllowed(.camera)
            let isAllowedLoc = SPPermission.isAllowed(.locationWhenInUse)
            let isAllowedLib = SPPermission.isAllowed(.photoLibrary)
            let boolArray:[Bool]=[isAllowedCamera,isAllowedLoc,isAllowedLib]
            let itemArray:[SPPermissionType]=[SPPermissionType.camera,SPPermissionType.locationAlwaysAndWhenInUse,SPPermissionType.photoLibrary]
            var toAsk:[SPPermissionType]=[]
            for i in 0...2{
                if(boolArray[i]==false){
                    toAsk.append(itemArray[i])
                }
            }
            SPPermission.Dialog.request(with: toAsk, on: self)
        }
    func setUpLocation(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        hud.show(in: self.view,animated: true)
        locationManager.startUpdatingLocation()
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("called")
        let location:CLLocation = locations[0]
        let coordinate:CLLocationCoordinate2D = location.coordinate
        locationManager.stopUpdatingLocation()
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate, completionHandler:{(resp,error)  in
            self.hud.dismiss()
            if(error != nil || resp==nil ){
                showAlert(msg: "You may have connectivity issues :"+error!.localizedDescription)
            }else{
                print(resp?.results()?.first)
                self.addressLbl.text = resp?.results()?.first?.thoroughfare
            }
            
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
