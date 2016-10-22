//
//  UserInformationClient.swift
//  On The Map
//
//  Created by Andrew Olson on 8/15/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//

import UIKit

struct UserInfo
{
    var objectId: String!
    var uniqueKey: String!
    var firstName: String!
    var lastName: String!
    var mapString: String!
    var mediaURL: String!
    var latitude: Double!
    var longitude: Double!
   
    init(){}
   
    init(
         objectId: String, uniqueKey: String, firstName: String
        ,lastName : String, mapString: String, mediaURL: String, latitude: Double, longitude: Double
        )
    {
        self.objectId = objectId
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.latitude = latitude
        self.longitude = longitude
    }
    init(dict: [String: String])
    {
        self.objectId = dict["objectId"]
        self.uniqueKey = dict["uniqueKey"]
        self.firstName = dict["firstName"]
        self.lastName = dict["lastName"]
        self.mapString = dict["mapString"]
        self.mediaURL = dict["mediaURL"]
        if let latitude = Double(dict["latitude"]!), longitude = Double(dict["longitude"]!)
        {
            self.latitude = latitude
            self.longitude = longitude
        }
    }
}
