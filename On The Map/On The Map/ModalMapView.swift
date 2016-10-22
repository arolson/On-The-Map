//
//  ModalMapView.swift
//  On The Map
//
//  Created by Andrew Olson on 8/19/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//

import UIKit
import MapKit


//Revise Entire Page!!
class ModalMapView: UIViewController, UITextFieldDelegate, MKMapViewDelegate
{
    let MMVInstance = MMVClient.getSharedInstance()
      
    @IBOutlet weak var mediaTextField: UITextField!
    
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var findLocationButton: UIButton!
    
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad()
    {
        MMVInstance.getPublicUserData()
        subscribeToKeyboardNotifications()
    }
    override func viewWillDisappear(animated: Bool) {
        unsubscribeToKeyboardNotifications()
    }
    
    
    /* Mark: Button Actions */
    @IBAction func cancelAction(sender: UIButton)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    
    }
    @IBAction func findLocationAction(sender: UIButton)
    {
         enableView(false)
        checkTextFields(
                        mapString: self.locationTextField.text!,
                        message: MMVClient.ErrorStrings.findError.rawValue
                        )
        {
            mapString , mediaURL in
            self.MMVInstance.findLocation(self, mapString: mapString,submit: false)
            self.enableView(true)
        }
        
    }
    @IBAction func submitAction(sender: UIButton)
    {
        enableView(false)
        checkTextFields(
                        self.mediaTextField.text!,
                        mapString: self.locationTextField.text!,
                        message:MMVClient.ErrorStrings.submitError.rawValue
                        )
        {
            mapString , mediaURL in
            
            self.MMVInstance.findLocation(self, mapString: mapString,mediaURL: mediaURL!, submit: true)
            self.enableView(true)
        }
    }
    
    func enableView(enable: Bool)
    {
        self.mediaTextField.enabled = enable
        self.locationTextField.enabled = enable
        self.findLocationButton.enabled = enable
        self.submitButton.enabled = enable
        
    }
    func checkTextFields(mediaURL: String? = nil,mapString: String, message: String,completionHandler: ((mapSting: String, mediaURL: String? ) ->Void)?)
    {
        if mediaURL == "" || mapString == ""
        {
            showErrorAlert(message)
            self.enableView(true)
            return
        }
        completionHandler!(mapSting: mapString,mediaURL: mediaURL)
    }

        /* Mark: MapView Delegate Functions */
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.tintColor = UIColor.redColor()
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    /*Mark: KeyBoard Notifications */
    func subscribeToKeyboardNotifications()
    {
        mediaTextField.delegate = self
        locationTextField.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self,selector: nil,name: UIKeyboardWillShowNotification,object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,selector: nil,name: UIKeyboardWillHideNotification,object: nil)
    }
    
    func unsubscribeToKeyboardNotifications()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self,name: UIKeyboardWillShowNotification,object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,name: UIKeyboardWillHideNotification,object: nil)
    }
    
    /*Mark: TextField Delegate */
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder() 
        return true
    }
}
