/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var riderLabel: UILabel!
    
    @IBOutlet weak var `switch`: UISwitch!
    
    @IBOutlet weak var driverLabel: UILabel!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
     var signUpState = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser() != nil{
             dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("loginRider", sender: self)
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    
    @IBAction func signUp(sender: AnyObject) {
        if username.text == "" || password.text == "" {
            
            displayAlert("Missing Field(s)", message: "Username and password are required")
            
        } else {
            
            if signUpState == true {
                
                let user = PFUser()
                user.username = username.text
                user.password = password.text
                
                
                user["isDriver"] = `switch`.on
                
                user.signUpInBackgroundWithBlock {
                    (succeded, error) -> Void in
                    if let error = error {
                        if let errorString = error.userInfo["error"] as? String {
                            
                            self.displayAlert("Sign Up Failed", message: errorString)
                            
                        }
                        
                        
                    } else {
                        
                        if self.`switch`.on == true {
                             dispatch_async(dispatch_get_main_queue()) {
                            
                               self.performSegueWithIdentifier("loginDriver", sender: self)
                            }
                            
                        } else {
                             dispatch_async(dispatch_get_main_queue()) {
                                self.performSegueWithIdentifier("loginRider", sender: self)
                            }
                            
                        }

                        
                    }
                    
                }
            }
        }
        

    }
    
    
    @IBAction func login(sender: AnyObject) {
        
        
        PFUser.logInWithUsernameInBackground(username.text!, password:password.text!) {
            (user: PFUser?, error: NSError?) -> Void in
            
            
            if PFUser.currentUser() != nil{
                
                if  user!["isDriver"]! as! Bool == true {
                     dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("loginDriver", sender: self)
                    }
                    
                } else {
                     dispatch_async(dispatch_get_main_queue()) {
                         self.performSegueWithIdentifier("loginRider", sender: self)
                    }
                    
                }
                
            } else {
                
                if let errorString = error?.userInfo["error"] as? String {
                    
                    self.displayAlert("Login Failed", message: errorString)
                    
                }
                
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        username.resignFirstResponder()
        
        password.resignFirstResponder()
        
        return true
    }
   
}
