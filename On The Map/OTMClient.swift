//
//  OTMClient.swift
//  On The Map
//
//  Created by Andrew Olson on 8/14/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//

import UIKit
//Here is where we will parse all of the ON THE MAP STUDENT Information we need for that view

class OTMClient
{
    //create a shared Instance that is thread safe
    static let SharedInstance = OTMClient()
    
    class func getSharedClient()->OTMClient
    {
        return SharedInstance
    }
    private init(){}
    
    enum OTMError
    {
        case Error
        
        case NoError
        
        case DoesNotExist
    }
    
    //URLInstance
    let URLInstance = URLClient.getSharedInstance()
    
    func getCurrentUser(uniqueKey: String,completionHandler: (results: NSDictionary?,error: OTMClient.OTMError)->Void)
    {
        
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(uniqueKey)%22%7D"
        print(urlString)
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        URLInstance.taskFromRequest(request)
        {   data, error in
            
            switch(error)
            {
                case .Error:
                    completionHandler(results: nil,error: .Error)
                
                case .NOError:
                    let parsedResult = self.URLInstance.parseData(data)
                    {
                        message in
                        completionHandler(results: ["error": message], error: .Error)
                    }
                    guard let results = parsedResult["results"] as? NSDictionary
                    else
                    {
                        print("Could Not Parse User Results")
                         completionHandler(results: nil,error: .DoesNotExist)
                        return
                    }
                    completionHandler(results: results,error: .NoError)
            }
        }
        
    }
    func getStudents(completionHandler: ([UserInfo])->(Void))
    {
        let methodParameters:[String:AnyObject] =
            [
                URLClient.UdacityParameterKeys.limit:URLClient.UdacityParameterValues.limit,URLClient.UdacityParameterKeys.skip:URLClient.UdacityParameterValues.skip,URLClient.UdacityParameterKeys.order:URLClient.UdacityParameterValues.order
            ]
        
        let url = URLInstance.buildURLFromParameters(methodParameters)
        
        let request = NSMutableURLRequest(URL: url)
        
        request.addValue(URLClient.UdacityParameterValues.appId, forHTTPHeaderField: URLClient.UdacityParameterKeys.appId)
        
        request.addValue(URLClient.UdacityParameterValues.APIKey, forHTTPHeaderField: URLClient.UdacityParameterKeys.APIKey)
        
        /* Send the request, if an Error has occured then send a custom Error Message,
         else execute Completion Handeler */
        URLInstance.taskFromRequest(request)
        {
            data, error in
            
            let parsedResult = self.URLInstance.parseData(data)
            {
                message in
                completionHandler([UserInfo]())
            }
            
            guard let results = parsedResult[JSONOnTheMapParameterKeys.results] as? [NSDictionary]
                else
            {
                print("Could not find Key for results!")
                completionHandler([UserInfo]())
                return
            }
            print(results)
            if let students = self.parseStudents(results)
            {
            
                completionHandler(students)
            }
            else
            {
                print("Could not parse Students")
            }
        }
    }
    private func parseStudents(results: [NSDictionary])->[UserInfo]?
    {
        var strudents = [UserInfo]()
        for i in results
        {
            //some idiot didnt have a name in the file
           if let firstName = i[JSONOnTheMapParameterKeys.firstName] as? String,
             lastname = i[JSONOnTheMapParameterKeys.lastName] as? String,
                latitude = i[JSONOnTheMapParameterKeys.latitude] as? Double,
             longitued = i[JSONOnTheMapParameterKeys.longitude] as? Double,
             mapString = i[JSONOnTheMapParameterKeys.mapString] as? String,
             mediaURL = i[JSONOnTheMapParameterKeys.mediaURL] as? String,
             objectId = i[JSONOnTheMapParameterKeys.objectId] as? String,
             uniqueKey = i[JSONOnTheMapParameterKeys.uniqueKey] as? String
           {
                let student = UserInfo (
                
                    objectId: objectId, uniqueKey: uniqueKey,firstName: firstName,lastName: lastname,
                    mapString: mapString, mediaURL:mediaURL,latitude: latitude,longitude: longitued
                
                )
                strudents.append(student)
                print(student.firstName)
            }
            
            print("")
        }
        return strudents
    }

}