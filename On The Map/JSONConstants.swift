//
//  JSONParameters.swift
//  On The Map
//
//  Created by Andrew Olson on 8/14/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//

import Foundation
struct JSONOnTheMapParameterKeys
{
    static let results = "results"
    static let objectId = "objectId"
    static let uniqueKey = "uniqueKey"
    static let firstName = "firstName"
    static let lastName = "lastName"
    static let mapString = "mapString"
    static let mediaURL = "mediaURL"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let createdAt = "createdAt"
    static let updatedAt = "updatedAt"
    static let ACL = "ACL"
}
struct JSONLoginParameterKeys
{
    static let session = "session"
    static let error = "error"
    static let account = "account"
    static let id = "id"
    static let key = "key"
}