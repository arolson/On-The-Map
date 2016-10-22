//
//  Constants.swift
//  On The Map
//
//  Created by Andrew Olson on 8/14/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//

import UIKit

class URLClient
{
    //create a shared Instance that is thread safe
    static let SharedInstance = URLClient()
    
    class func getSharedInstance()->URLClient
    {
        return SharedInstance
    }
    private init(){}
    
    //states for retruning errors or not
    enum Error
    {
        case Error
        
        case NOError
    
    }
    //MARK: Udacity URL Constants
    struct UdacityParameterKeys
    {
        static let appId = "X-Parse-Application-Id"
        static let APIKey = "X-Parse-REST-API-Key"
        static let limit = "limit"
        static let skip = "skip"
        static let order = "order"
    }
    
    struct UdacityParameterValues
    {
        static let appId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let limit = 100
        static let skip = 200
        static let order = "-updatedAt"
    }
    
    //MARK: NSURLComponents for Student Location
    func buildURLFromParameters(parameters: [String:AnyObject], withExtension: String? = nil)->NSURL
    {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "parse.udacity.com"
        urlComponents.path = "/parse/classes/StudentLocation" + (withExtension ?? "")
        urlComponents.queryItems = [NSURLQueryItem]()
    
        return urlComponents.URL!
    }
    
    //MARK: Check For Errors
    func checkForErrors(data: NSData?,response: NSURLResponse?,error:NSError?)->String?
    {
        let displayError =
        {
            (s:String)->String? in
            print(s)
        return s
        }
        /* GUARD: Was there an error? */
        guard (error == nil)
        else
        {
            return displayError("There was an error with your request: \(error)")
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode
            where statusCode >= 200 && statusCode <= 299
        else
        {
            return displayError("Your request returned a status code other than 2xx!")
        }
        
        /* GUARD: Was there any data returned? */
        guard data != nil
        else
        {
            return displayError("No data was returned by the request!")
        }
       return nil
    }
    
    //MARK: Task From Request
    func taskFromRequest(request: NSMutableURLRequest?,completionHandler:(data:NSData?,error: Error)->Void)
    {
        let session = NSURLSession.sharedSession()
        if let request = request
        {
            let client = URLClient()
            
            let task = session.dataTaskWithRequest(request)
            {
                data, response, error in
            
                if client.checkForErrors(data, response: response, error: error) != nil
                {
                    completionHandler(data: data,error: .Error)
                }
                else
                {
                    completionHandler(data: data,error: .NOError)
                }
            }
            task.resume()
        }
    }
    
    //MARK: Parse Data
    func parseData(data: NSData?,errorHandeler: (message: String)->Void)->AnyObject
    {
        var parsedResult: AnyObject!
        do
        {
            if let data = data
            {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            }
            else
            {
                let message = "Data Retruned Empty!"
                errorHandeler(message: message)
                return message
            }
        }
        catch
        {
            print("Could not retrieve Students Information \(data)")
        }
        
        return parsedResult
        
    }
}
