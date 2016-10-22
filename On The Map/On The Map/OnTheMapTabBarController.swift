//
//  OnTheMapTabBarController.swift
//  On The Map
//
//  Created by Andrew Olson on 8/17/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//

import UIKit

class OnTheMapTabBarController: UITabBarController
{
    let URLInstance = URLClient.getSharedInstance()
    let OTMInstance = OTMClient.getSharedClient()
    let classroomInstance = Classroom.getSharedInstance()
    
    private let ModalMapViewIdentifier = "ModalMapViewController"
    
    /*Mark: Actions */
    @IBAction func pinAction(sender: UIBarButtonItem)
    {
        placePin()
    }
    @IBAction func refreshAction(sender: AnyObject)
    {
        refresh()
    }
    
    @IBAction func logoutAction(sender: AnyObject)
    {
        deleteSessionID()
    }
    
    /*Mark: Place Pin */
    func placePin()
    {
        let uniqueKey = classroomInstance.getStudent().uniqueKey

        OTMInstance.getCurrentUser(uniqueKey)
        {
            results,error in
            performUIUpdatesOnMain(){
            switch (error)
            {
                case .Error:
                    //Display Error message
                    self.showErrorAlert("Could not get current user Location.")
                case .NoError:
                    //Display Alert to Overwrite Current pin
                    self.presentViewController(self.showModalAlert(), animated: true, completion: nil)
                
                case .DoesNotExist:
                    //Display The Modal ViewController
                    print("User Does Not Exits")
                   self.performSegueWithIdentifier(self.ModalMapViewIdentifier, sender: self)
                }
            }
        }
    }
    
    /*Mark: Refresh */
    func refresh()
    {
        if let otmMap = self.childViewControllers[0] as? OnTheMapViewController,
            otmList = self.childViewControllers[1] as? OnTheMapTableViewController
        {
            otmMap.mapView.removeAnnotations(otmMap.mapView.annotations)
            otmMap.initializeStudents()
            otmList.initializeStudents()
        }
        
    }
    
    /*MARK: LogoutSession */
    func deleteSessionID()
    {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie
        {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
    
        URLInstance.taskFromRequest(request)
        {
            data, error in
    
            /* subset response data! */
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            let parsedResponse = self.URLInstance.parseData(newData)
            {
                message in
                print(message)
            }
            print(parsedResponse)
            
            performUIUpdatesOnMain(){
            self.parseLogoutSession(error, parsedResponse: parsedResponse)
            }
        }
           
    }
    func parseLogoutSession(error: URLClient.Error,parsedResponse: AnyObject)
    {
        switch(error)
        {
        //display an error
        case .Error:
            
            let message = "Could Not Logout"
            self.showErrorAlert(message)
        //success dismiss view
        case .NOError:
            //Success 
            if let _ = parsedResponse["session"] as? NSDictionary
            {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }

    func showModalAlert()->UIAlertController
    {
        let message = "Would you like to Move your Pin?"
        let alert = UIAlertController(title: "Pin",message: message, preferredStyle: .Alert )
        alert.addAction(UIAlertAction(title: "Dismiss",style: .Cancel,handler: nil))
        alert.addAction(UIAlertAction(title: "OK",style: .Cancel){
            alert in
                self.performSegueWithIdentifier(self.ModalMapViewIdentifier, sender: self)
            })
        return alert
    }

}
