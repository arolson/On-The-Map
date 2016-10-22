//
//  UserAccountClient.swift
//  On The Map
//
//  Created by Andrew Olson on 8/27/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//

import UIKit

class AccountClient
{
    //create a shared Instance that is thread safe
    static let SharedInstance = AccountClient()
    
    class func getSharedInstance()->AccountClient
    {
        return SharedInstance
    }
    private init(){}
    
    let URLInstance = URLClient.getSharedInstance()
    let classroomInstance  = Classroom.getSharedInstance()
    
    private struct LoginComponents
    {
        static let scheme = "https"
        static let host = "www.udacity.com"
        static let postPath = "/api/session"
        static let post = "POST"
        static let value = "application/json"
        static let acceptHeader = "Accept"
        static let contentHeader = "Content-Type"
    }

    func LoginPostURL()->NSURL
    {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = LoginComponents.scheme
        urlComponents.host = LoginComponents.host
        urlComponents.path = LoginComponents.postPath
        urlComponents.queryItems = nil
        print(urlComponents.URL!)
        return urlComponents.URL!
    }
    /* MARK: Build a POST Request */
    func buildPOSTRequest()->NSMutableURLRequest
    {
        let request = NSMutableURLRequest(URL: LoginPostURL())
        
        request.HTTPMethod = LoginComponents.post
        
        request.addValue(LoginComponents.value, forHTTPHeaderField: LoginComponents.acceptHeader)
        request.addValue(LoginComponents.value, forHTTPHeaderField: LoginComponents.contentHeader)
        return request
    }
    
    /* MARK: Get Request */
    func getSessionIdAndAccountKey(username: String,password: String,completionHandler: (message: String)->Void)
    {
        if username == "" || password == ""
        {
            let message = "Invalid Username or Password!"
            completionHandler(message: message)
            return
        }
        let request = self.buildPOSTRequest()
        let JSONPOSTString = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        request.HTTPBody = JSONPOSTString.dataUsingEncoding(NSUTF8StringEncoding)
        
        /* Send the request, if an Error has occured then send a custom Error Message,
         else execute Completion Handeler */
        URLInstance.taskFromRequest(request)
        {
            data , error in
            
            /* subset response data? */
           guard let newData = data?.subdataWithRange(NSMakeRange(5, data!.length - 5))
           else
           {
                completionHandler(message: "Could not retrieve Data!")
                return
            }
            
            let parsedResult = self.URLInstance.parseData(newData)
            {
                message in
                completionHandler(message: message)
            }
            
            switch (error)
            {
            case .Error:
                self.parseError(parsedResult)
                {
                    message in
                    completionHandler(message: message)
                }
                
            case .NOError:
               self.parseAccountKey(parsedResult)
                completionHandler(message: "Success")
            }
        }
    }
    //If there is an error Display It
    func parseError(parsedResult: AnyObject,errorHandler: (message: String)->Void)
    {
        
        if let message = parsedResult[JSONLoginParameterKeys.error] as? String
        {
            
            performUIUpdatesOnMain()
            {
                errorHandler(message: message)
            }
        }
        else
        {
            print("Could Not Parse Error")
        }
    }
    func parseAccountKey(parsedResult: AnyObject)
    {
        if let account = parsedResult[JSONLoginParameterKeys.account] as? NSDictionary,
            uniqueKey = account[JSONLoginParameterKeys.key] as? String
        {
            self.saveUniqueKey(uniqueKey)
        }
        else
        {
            print("Could Not Parse account Key")
        }
    }
    private func saveUniqueKey(uniqueKey: String)
    {
        
        classroomInstance.student.uniqueKey = uniqueKey
    }
}