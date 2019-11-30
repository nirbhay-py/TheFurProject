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
    var newReportType:reportType!
    
    let btn1 = UIButton(frame: CGRect(x:33,y:0,width:150,height:50))
    let btn2 = UIButton(frame: CGRect(x:33,y:60,width:150,height:50))
    let btn3 = UIButton(frame: CGRect(x:33,y:120,width:150,height:50))
    let subview = UIView(frame: CGRect(x:0,y:0,width:216,height:170))

    let appearance = SCLAlertView.SCLAppearance(
        showCloseButton: false,
        shouldAutoDismiss: true
    )
    lazy var alert = SCLAlertView(appearance: appearance)
    
    
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
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:Selector(("dismissAlert")))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissAlert(){
        print("called")
        self.alert.hideView()
        
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
                self.addressLbl.text = resp?.results()?.first?.subLocality
            }
            
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    @IBAction func newIssue(_ sender: Any) {
        createSubview()
    }
    @IBAction func map(_ sender: Any) {
    }
    @IBAction func pastIssues(_ sender: Any) {
    }
    
    //MARK:Input subview
    
    func createSubview(){
        
        // Create the subview
        print(subview.frame.width)
        btn1.setTitleColor(UIColor.systemYellow, for: .normal)
        btn1.backgroundColor = UIColor.systemIndigo
        btn1.setTitle("Injured animal", for: .normal)
        btn1.layer.cornerRadius = 10
        btn2.layer.cornerRadius = 10
        btn3.layer.cornerRadius = 10
        btn1.addTarget(self, action: #selector(self.btn1Clicked), for: .touchUpInside)
        subview.addSubview(btn1)
        btn2.setTitleColor(UIColor.systemYellow, for: .normal)
        btn2.backgroundColor = UIColor.systemIndigo
        btn2.setTitle("Adoption", for: .normal)
        btn2.addTarget(self, action: #selector(self.btn2Clicked), for: .touchUpInside)
        subview.addSubview(btn2)
        btn3.setTitleColor(UIColor.systemYellow, for: .normal)
        btn3.backgroundColor = UIColor.systemIndigo
        btn3.setTitle("Animal abuse", for: .normal)
        btn3.addTarget(self, action: #selector(self.btn3Clicked), for: .touchUpInside)
        subview.addSubview(btn3)
        // Add the subview to the alert's UI property
        alert.customSubview = subview
        alert.showNotice("What happened?", subTitle: "")
        
    }
    
    @objc func btn1Clicked(){
        newReportType = .injuredAnimal
        self.btn1.flash()
        self.alert.hideView()
        self.performSegue(withIdentifier: "issueVC", sender: self)
    }
    @objc func btn2Clicked(){
        newReportType = .adoptionType
        self.btn2.flash()
        self.alert.hideView()
        self.performSegue(withIdentifier: "issueVC", sender: self)

    }
    @objc func btn3Clicked(){
        newReportType = .animalAbuse
        self.btn3.flash()
        self.alert.hideView()
        self.performSegue(withIdentifier: "issueVC", sender: self)
    }

        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier=="issueVC"){
            let destVC = segue.destination as! issueVC
            destVC.reportType = self.newReportType
            destVC.user = self.thisUser
        }else if(segue.identifier=="toMap"){
            let destVC = segue.destination as! mapVC
            destVC.thisUser = self.thisUser
        }
    }
}


