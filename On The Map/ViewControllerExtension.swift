//
//  ViewControllerExtension.swift
//  On The Map
//
//  Created by Andrew Olson on 8/26/16.
//  Copyright © 2016 Andrew Olson. All rights reserved.
//

import UIKit

extension UIViewController
{
    func showErrorAlert(message: String)
    {
        let alert = UIAlertController(title: "Error",message: message,preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK",style: .Cancel,handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
