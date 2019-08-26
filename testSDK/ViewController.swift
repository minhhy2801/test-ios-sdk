//
//  ViewController.swift
//  testSDK
//
//  Created by Hoang Yen Minh on 8/26/19.
//  Copyright © 2019 Hoang Yen Minh. All rights reserved.
//

import UIKit
import kintone_ios_sdk
import Promises

class ViewController: UIViewController {
    
    @IBOutlet weak var txtAppId: UITextField!
    @IBOutlet weak var txtDomain: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnGetApp: UIButton!
    @IBOutlet weak var txtDescription: UITextView!
    
    let auth:Auth = Auth()
    var conn:Connection? = nil
    var app:App? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func getApp(_ sender: Any) {
        let (isValid, errorString) = self.isFieldsValid()
        if(!isValid){
            DispatchQueue.main.async {
                var htmlString = "<html><head></head><body><h1>Error occur</h1>"
                htmlString += "<p><b>Message: \(errorString)</b></p>"
                htmlString += "</body></head></html>"
                self.txtDescription.attributedText = self.getAttributedString(htmlString)
            }
            return
        }
        auth.setPasswordAuth(txtUsername.text!, txtPassword.text!)
        conn = Connection(txtDomain.text!, auth)
        app = App(conn)

        self.app?.getApp(Int(txtAppId.text!)!).then{ response in
            let htmlString = "<html>" +
                "<head></head>" +
                "<body><h1>App Infor</h1>" +
                "<b>App ID: \(response.getAppId()!)</b></br>" +
                "<b>App Name: \(response.getName()!)</b></br>" +
                "<b>Creared At: \(response.getCreadtedAt()!)</b></br>" +
                "<b>Creared By: \(response.getCreator()!.getName()!)</b></br>" +
            "</body></head></html>"

            DispatchQueue.main.async {
                self.txtDescription.attributedText = self.getAttributedString(htmlString)
            }
            }.catch { error in
                var htmlString = "<html><head></head><body><h1>Error occur</h1>"

                if type(of: error) == KintoneAPIException.self
                {
                    let err = error as! KintoneAPIException
                    htmlString += "<b>Status code: \(err.getHttpErrorCode()!)</b>" +
                    "<p><b>Message: \(err.getErrorResponse()!.getMessage()!)</b></p>"
                } else {
                    htmlString += "<p><b>Message: \(error.localizedDescription)</b></p>"
                }

                htmlString += "</body></head></html>"

                DispatchQueue.main.async {
                    self.txtDescription.attributedText = self.getAttributedString(htmlString)
                }
        }
    }
    
    func isFieldsValid() -> (Bool, String) {
        var errorString: String = ""
        var isValid: Bool = true
        if(txtDomain.text!.isEmpty)
        {
            isValid = false
            errorString = "Please input domain field"
            return (isValid, errorString)
        }
        if(txtUsername.text!.isEmpty)
        {
            isValid = false
            errorString = "Please input username field"
            return (isValid, errorString)
        }
        if(txtPassword.text!.isEmpty)
        {
            isValid = false
            errorString = "Please input Password field"
            return (isValid, errorString)
        }
        if(txtAppId.text!.isEmpty)
        {
            isValid = false
            errorString = "Please input app ID field"
            return (isValid, errorString)
        }
        return (isValid, "")
    }
    
    func getAttributedString(_ htmlString: String) -> NSAttributedString {
        let htmlData = NSString(string: htmlString).data(using: String.Encoding.unicode.rawValue)
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        let attributedString = try! NSAttributedString(data: htmlData!, options: options, documentAttributes: nil)
        return attributedString
    }
}

