//
//  ViewController.swift
//  TheFurProject
//
//  Created by Nirbhay Singh on 22/11/19.
//  Copyright © 2019 Nirbhay Singh. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import JGProgressHUD
import CoreData


class mainVC: UIViewController,  GIDSignInDelegate{

    @IBOutlet weak var mainConst: NSLayoutConstraint!
    var globalUser:UserClass!
    
    override func viewWillAppear(_ animated: Bool) {
           
          
        navigationController?.setNavigationBarHidden(true, animated: animated)
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
//        GIDSignIn.sharedInstance().signIn()
        mainConst.constant -= view.bounds.width
        view.layoutIfNeeded()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.7, animations: {
            self.mainConst.constant += self.view.bounds.width
            self.view.backgroundColor = UIColor.systemIndigo;
            self.view.layoutIfNeeded()
        })
    

    }
    
    
    override func viewDidLoad() {

        if(Auth.auth().currentUser != nil){
            print("signed in")
            getSignedInDetails()
            self.performSegue(withIdentifier: "signInSegue", sender: self)
        }
        super.viewDidLoad()
    }

  
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
      }
      let hud = JGProgressHUD.init()
      hud.show(in:self.view, animated: true)
      guard let authentication = user.authentication else { return }
      let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
      Auth.auth().signIn(with: credential) { (authResult, error) in
        if let error = error {
            hud.dismiss()
            showAlert(msg: error.localizedDescription)
          return
        }
        //MARK:create a user
        let userId = user.userID
        let name = user.profile.name
        let email = user.profile.email
        let givenName = user.profile.givenName
        let photoURL = user.profile.imageURL(withDimension: 150)?.absoluteString
        
        //MARK:CoreData code goes here
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        let newUser = NSManagedObject(entity: entity!, insertInto: context)
        newUser.setValue(userId, forKey: "userID")
        newUser.setValue(name, forKey: "fullName")
        newUser.setValue(givenName, forKey: "givenName")
        newUser.setValue(photoURL, forKey:"photoURL")
        newUser.setValue(email, forKey: "email")
        
        do{
            try context.save()
            print("saved...")
        } catch {
            showAlert(msg: "We could not save your data!")
        }
        

        
        let userDic = [
            "userID":userId!,
            "givenName":givenName ?? "Empty",
            "name":name!,
            "email":email!,
            "photoURL":photoURL as Any,
            ] as [String : Any]
        let strippedEmail = splitString(str:email!, delimiter:".")
        let ref = Database.database().reference().child("user-node").child(strippedEmail)
        self.globalUser = UserClass(fullName:name!,email:email!,userID:userId!,photoURL:photoURL!,givenName:givenName!)
        ref.setValue(userDic) { (error, ref) -> Void in
            if(error != nil){
                hud.dismiss()
                showAlert(msg: error?.localizedDescription ?? "There seems to be something wrong with your connection.")
            }else{
                hud.dismiss()
                showSuccess(msg: "Signed in with success!")
                self.performSegue(withIdentifier: "signInSegue", sender: self
                )
            }
        }
      }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier=="signInSegue"){
            let toNext = segue.destination as! dashboardVC
            toNext.thisUser = globalUser
        }
       
    }
    
    func getSignedInDetails(){
        print("called")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        do {
            let resp = try managedContext.fetch(fetchRequest)
            let data = resp.first!
            self.globalUser = UserClass(fullName: data.value(forKey: "fullName") as! String, email: data.value(forKey: "email") as! String, userID: data.value(forKey: "userID") as! String, photoURL: data.value(forKey: "photoURL") as! String, givenName: data.value(forKey: "givenName") as! String)
            

        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
}

