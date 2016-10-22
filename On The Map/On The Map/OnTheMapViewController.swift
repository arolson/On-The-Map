//
//  ViewController.swift
//  On The Map
//
//  Created by Andrew Olson on 8/14/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//

import UIKit
import MapKit

class OnTheMapViewController: UIViewController, MKMapViewDelegate
{
    let OTMCLientInstance = OTMClient.getSharedClient()
    let classroomInstance = Classroom.getSharedInstance()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loadingvare view, typically from a nib.
        initializeStudents()
    }
    func initializeStudents()
    {
        OTMCLientInstance.getStudents()
        {
                students in
                if students.isEmpty
                {
                    self.showErrorAlert("No Student Information is available!")
                    return
                }
                self.classroomInstance.students = students
                
            performUIUpdatesOnMain()
            {
                self.setUpMap()
            }
        }
    }
    func setUpMap()
    {
            let locations = self.classroomInstance.students
            var annotations = [MKPointAnnotation]()
            for student in locations
            {
                let lat = CLLocationDegrees(student.latitude)
                let long = CLLocationDegrees(student.longitude)
                let coordinate = CLLocationCoordinate2D(latitude: lat,longitude: long)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(student.firstName) \(student.lastName)"
                annotation.subtitle = student.mediaURL
                annotations.append(annotation)
            }
            self.mapView.addAnnotations(annotations)
        
    }
    //Cannot get button to show no matter what I try
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

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        if control == view.rightCalloutAccessoryView
        {
            let app = UIApplication.sharedApplication()
            
            if let toOpen = view.annotation?.subtitle!
            {
                guard app.openURL(NSURL(string: toOpen)!)
                else
                {
                    print("bad URL")
                    return
                }
            }
        }
    }
    
}

