//
//  RegisterViewController.swift
//  AudioRecorder
//
//  Created by Subodh Sah on 6/5/16.
//  Copyright © 2016 Subodh Sah. All rights reserved.
//

import UIKit
import Parse

class RegisterViewController: UIViewController {

    let gotoAudiotable = "gotoAudiotable"
    
    @IBOutlet weak var emailText: UITextField!
    
    
    var emailValidCheck = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "Register"
        
        //if user already exists take him to his audio history
        if (PFUser.currentUser() != nil)
        {
            self.performSegueWithIdentifier(self.gotoAudiotable, sender: nil)
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAction(sender: AnyObject) {
      
        //check email text not empty
        if (!(emailText.text?.isEmpty)! == true)
        {
            
            emailValidCheck = emailText.text!
            
            //check email is valid
            if (isValidEmail(emailValidCheck))
            {
                
                let usernameArr = self.emailValidCheck.componentsSeparatedByString("@")
                let username: String = usernameArr[0]
                
                let user = PFUser()
                user.username = username
                user.password = username
                user.email = self.emailValidCheck
                
                //sign up the user
                user.signUpInBackgroundWithBlock { (succeeded, error) -> Void in
                    if (succeeded) {
                        //if succesful move to next segue
                        self.performSegueWithIdentifier(self.gotoAudiotable, sender: nil)
                    } else {
                        
                        PFUser.logInWithUsernameInBackground(username, password: username, block: { (user, error) -> Void in
                            
                            if error != nil {
                                
                                self.displayAlert("Registration failed!!")
                                
                            }
                            else
                            {
                                // if user exists and login sucessful,take to audio history for the user 
                                self.performSegueWithIdentifier(self.gotoAudiotable, sender: nil)
                                
                            }
                            
                        })
                        
                        
                    }
                }
                

            }
            else
            {
                displayAlert("Please Enter valid email ID")
            }
            
        }
        else{
            
            displayAlert("Enter an email address to login")
        
        }

}
    
    
    //check email is valid
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    

    //alert to display errors
    func displayAlert(message:String) {
        let alertController = UIAlertController(title: "Error", message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
