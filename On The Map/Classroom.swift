//
//  Classroom.swift
//  On The Map
//
//  Created by Andrew Olson on 8/22/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//

import UIKit

class Classroom
{
    static let sharedInstance = Classroom()
    class func getSharedInstance()-> Classroom
    {
        return self.sharedInstance
    }

    var student = UserInfo()
    var students =  [UserInfo]()
    
    //geters
    func getStudent()->UserInfo
    {
        return self.student
    }
    func getStudents()->[UserInfo]
    {
        return self.students
    }
    //seters
    func setStudent(student: UserInfo)
    {
        self.student = student
    }
    func setStudents(students: [UserInfo])
    {
        self.students = students
    } 
}