//
//  AlertExtension.swift
//  On The Map
//
//  Created by Andrew Olson on 8/19/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//

import UIKit

extension UIAlertController
{
    struct AlertActionParameters
    {
       
        var actionTitle: String!
        var actionStyle: UIAlertActionStyle!
        var handler: ((UIAlertAction)->Void)?
        
        init(
            actionStyle: UIAlertActionStyle, actionTitle: String,handler: ((UIAlertAction)->Void)?
            )
        {
            self.actionStyle = actionStyle
            self.actionTitle = actionTitle
            self.handler = handler
        }
    }
   static func createAlertWithActions(title: String,message: String, style: UIAlertControllerStyle, actions: [AlertActionParameters] = [])->UIAlertController
    {
        let alert = UIAlertController(title: title,message: message,preferredStyle: style)
        for i in actions
        {
            alert.addAction(UIAlertAction(title: i.actionTitle,style: i.actionStyle,handler: i.handler))
        
        }
        return alert
    }
}
