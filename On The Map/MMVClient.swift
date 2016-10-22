//
//  MMVClient.swift
//  On The Map
//
//  Created by Andrew Olson on 8/22/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//

import UIKit
import MapKit

class MMVClient
{

    let URLInstance = URLClient.getSharedInstance()
    let classroomInsatance = Classroom.getSharedInstance()
    
    static let sharedInstance = MMVClient()
    class func getSharedInstance()->MMVClient
    {
        return sharedInstance
    }
    
    private struct MMVURLComponents
    {
        static let scheme = "https"
        static let host = "www.udacity.com"
        static let getPath = "/api/users/"
    }
    private struct MMVJSONConstants
    {
        static let user = "user"
        static let firstName = "first_name"
        static let lastName = "last_name"
    }
    enum ErrorStrings: String
    {
         case submitError = "One or more of the parameters are empty!"
         case findError = "The location parameter is empty!"
    }
    func MMVgetURL(uniqueKey: String)->NSURL
    {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = MMVURLComponents.scheme
        urlComponents.host = MMVURLComponents.host
        urlComponents.path = MMVURLComponents.getPath + uniqueKey
        urlComponents.queryItems = [NSURLQueryItem]()
        print(urlComponents.URL)
        return urlComponents.URL!
    }
    
    func buildGetRequest()-> NSMutableURLRequest
    {
        let uniqueKey = classroomInsatance.student.uniqueKey
        let url = MMVgetURL(uniqueKey)
        let request = NSMutableURLRequest(URL: url)
        return request
    }
    
    func getPublicUserData()
    {
        let request = buildGetRequest()
        URLInstance.taskFromRequest(request)
        {
            data, error in
            
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            let parsedResult = self.URLInstance.parseData(newData)
            {
                message in
                print(message)
            }
            
            if let user = parsedResult[MMVJSONConstants.user] as? NSDictionary
            {
                if let firstName = user[MMVJSONConstants.firstName] as? String,
                    lastName = user[MMVJSONConstants.lastName] as? String
                {
                    print(firstName)
                    print(lastName)
                    //store first and last name of the user
                    self.classroomInsatance.student.firstName = firstName
                    self.classroomInsatance.student.lastName = lastName
                }
                else
                {
                    print("User: Could not Parse User!")
                }
            }
            else
            {
                print("User: Could not parse NSDictionary")
            }

        }
    }
    
    func findLocation(ModalMapViewController: ModalMapView, mapString: String, mediaURL: String? = nil ,submit: Bool)
    {
        
        //start or stop the activity Indicator
        let indicator = {
            (enable: Bool) -> Void in
            performUIUpdatesOnMain()
            {
                enable ?
                    ModalMapViewController.activityIndicator.startAnimating() :
                    ModalMapViewController.activityIndicator.stopAnimating()
            }
        }
        
        //get Location of User
        let geo = CLGeocoder()
        //start the Indicator
        indicator(true)
        geo.geocodeAddressString(mapString)
        {
            placemarks, error in
            guard error == nil
            else
            {
                let message = "Could not find location."
                ModalMapViewController.showErrorAlert(message)
                indicator(false)
                print(message)
                return
            }
            
            guard let placemarks = placemarks else {return}
            ModalMapViewController.mapView.showsUserLocation = false
            let p = placemarks[0]
            let mp = MKPlacemark(placemark: p)
            ModalMapViewController.mapView.removeAnnotations(ModalMapViewController.mapView.annotations)
            ModalMapViewController.mapView.addAnnotation(mp)
            
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(mp.coordinate, 1000, 1000)
            ModalMapViewController.mapView.setRegion(coordinateRegion, animated: true)
            
            let latitude = mp.coordinate.latitude
            let longitude = mp.coordinate.longitude
            print("User: lat \(latitude) long \(longitude)")
            
            self.classroomInsatance.student.latitude = latitude
            self.classroomInsatance.student.longitude = longitude
            self.classroomInsatance.student.mapString = mapString
            self.classroomInsatance.student.mediaURL = mediaURL
            
            if (submit)
            {
                self.postLocation()
                {
                    ModalMapViewController.showErrorAlert("Could Not Find Location")
                    indicator(false)
                    return
                }
                ModalMapViewController.dismissViewControllerAnimated(true, completion: nil)
            }
            //stop the activity indicator
           indicator(false)
        }
    }
    
    func postLocation(errorHandler: (Void)->Void)
    {
        let uniqueKey = classroomInsatance.getStudent().uniqueKey
        let firstname = classroomInsatance.getStudent().firstName
        let lastname = classroomInsatance.getStudent().lastName
        let mapString = classroomInsatance.getStudent().mapString
        let mediaURL = classroomInsatance.getStudent().mediaURL
        let latitude = classroomInsatance.getStudent().latitude
        let longitude = classroomInsatance.getStudent().longitude
        
        print("\(uniqueKey) + \(firstname) \(lastname) + \(mapString) + \(mediaURL) + \(mapString)")
        print("\(latitude) + \(longitude)")
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstname)\", \"lastName\": \"\(lastname)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil { // Handle error…
                errorHandler()
                return
            }
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
        }
        task.resume()
    }

}