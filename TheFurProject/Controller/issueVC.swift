//
//  issueVC.swift
//  TheFurProject
//
//  Created by Nirbhay Singh on 23/11/19.
//  Copyright © 2019 Nirbhay Singh. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
import CoreLocation
import GoogleMaps


class issueVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,CLLocationManagerDelegate{
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var txtView: UITextView!
    let picker = UIImagePickerController()
    let hud = JGProgressHUD.init()
    let locationManager = CLLocationManager()
    var locations:CLLocationCoordinate2D!
    var reportType:reportType!
    var user:UserClass!
    var img:Data!
    override func viewDidLoad() {
        txtView.layer.cornerRadius = 10
        super.viewDidLoad()
        picker.delegate = self
        setUpLocation()
    }
    @IBAction func submit(_ sender: Any) {
        if(txtView.text.count<20){
            showAlert(msg: "Looks like you need to type some more!")
        }else if(img==nil){
            showAlert(msg: "You must select an image!")
        }else if(img.count>8000000){
            showAlert(msg: "You must choose a ligher image file")
        }else{
            let hud = JGProgressHUD.init()
            hud.show(in: self.view, animated: true)
            let ref = Database.database().reference().child("reports-node").childByAutoId()
            let key = ref.key
            var reportString=""
            if(reportType == .injuredAnimal){
                reportString = "injured-animal"
            }else if(reportType == .animalAbuse){
                reportString = "animal-abuse"
            }else{
                reportString = "adoption-type"
            }
            let reportDic = [
                "full-name":user.fullName!,
                "given-name":user.givenName as Any,
                "email":user.email as Any,
                "user-id":user.userID as Any,
                "report-type":reportString as Any,
                "location-lat":self.locations.latitude as Any,
                "location-lon":self.locations.longitude as Any,
                "desc":txtView.text as Any,
                "upvotes":1
                ] as [String : Any]
            
            
            
            
            ref.setValue(reportDic){error,ref -> Void in
            
               if(error == nil){
                let storage = Storage.storage()
                let storageRef = storage.reference().child("report-images").child(ref.key!)
                    _ = storageRef.putData(self.img, metadata: nil) { (metadata, error) in
                        if(error == nil){
                            showSuccess(msg:"This alert has been issued successfully!")
                            hud.dismiss()
                            self.txtView.text = ""
                            self.img=nil
                            self.performSegue(withIdentifier: "back", sender: self)
                        }else{
                            hud.dismiss(animated: true)
                            showAlert(msg: error!.localizedDescription)
                        }
                    }
                }else{
                    hud.dismiss(animated: true)
                    showAlert(msg: error!.localizedDescription)
                }
                
            }
        }
        
    }
    
    @IBAction func camera(_ sender: Any) {
        picker.allowsEditing = false
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
    }
    @IBAction func library(_ sender: Any) {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.img = pickedImage.pngData()
        }
        dismiss(animated: true, completion: nil)
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
            self.locations = coordinate
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
}
