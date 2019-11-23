//
//  appUtilities.swift
//  TheFurProject
//
//  Created by Nirbhay Singh on 22/11/19.
//  Copyright © 2019 Nirbhay Singh. All rights reserved.
//

import Foundation
import UIKit
import SCLAlertView

func showAlert(msg:String){
    SCLAlertView().showError("Oops!", subTitle:msg)
}

func showSuccess(msg:String){
    SCLAlertView().showSuccess("Success", subTitle: msg)
}

func isValidEmail(emailStr:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: emailStr)
}

func splitString(str:String,delimiter:String) -> String{
    var returnString = ""
    for char in str {
        if(String(char) != delimiter){
            returnString += String(char)
        }else{
            returnString += String("-")
        }
    }
    return returnString
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

extension UIButton{
    func pulsate(){
        let pulse = CASpringAnimation(keyPath: "transform.scale");
        pulse.duration = 0.4
        pulse.fromValue = 0.95
        pulse.toValue = 1
        pulse.autoreverses = true
        pulse.repeatCount = 1
        pulse.initialVelocity = 5
        pulse.damping = 1
        layer.add(pulse, forKey: nil)
    }
    func flash() {
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.3
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 1
        layer.add(flash, forKey: nil)}
}
