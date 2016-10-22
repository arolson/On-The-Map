//
//  OnTheMapTableViewController.swift
//  On The Map
//
//  Created by Andrew Olson on 8/18/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//

import UIKit

class OnTheMapTableViewController: UITableViewController
{
    
    let OTMInstance = OTMClient.getSharedClient()
    let classroomInstance = Classroom.getSharedInstance()
    
    @IBOutlet var listTableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    override func viewWillAppear(animated: Bool)
    {
        initializeStudents()
    }
    func initializeStudents()
    {
        OTMInstance.getStudents()
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
                        if let _ = self.listTableView
                        {
                            self.listTableView.reloadData()
                        }
                        else
                        {
                            print("TableView Does not Exist")
                        }
                }
        }
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.classroomInstance.students.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "Cell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId,forIndexPath: indexPath) as UITableViewCell
        
        let name = "\(self.classroomInstance.students[indexPath.row].firstName) \(self.classroomInstance.students[indexPath.row].lastName)"
        
        cell.textLabel?.text = name
        cell.imageView?.image = UIImage(named: "Pin")
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
            let app = UIApplication.sharedApplication()
            let mediaURL = self.classroomInstance.students[indexPath.row].mediaURL
            guard app.openURL(NSURL(string: mediaURL)!)
            else
            {
                print("Not A URL!")
                return
            }
    }
}
