//
//  APIHelperS.swift
//  APIHelper
//
//  Created by Chandra Rao on 08/09/17.
//  Copyright © 2017 Chandra Rao. All rights reserved.
//

import UIKit

class APIHelperS: NSObject {
    
    // MARK: - Shared Instance
    
    static let sharedInstance: APIHelperS = {
        let instance = APIHelperS()
        // setup code
        return instance
    }()
    
    // MARK: - Initialization Method
    
    override init() {
        super.init()
    }
    
    func callPostApi(withMethod methodName: String, andPost bodyData: Data, successHandler: @escaping (_ dictData: NSDictionary) -> Void, failureHandler: @escaping (_ strMessage: String) -> Void) {
        
        let json = ["IdSurvey":"102","IdUser":"iOSclient","UserInformation":"iOSClient"]
        
        let data : NSData = NSKeyedArchiver.archivedData(withRootObject: json) as NSData
        JSONSerialization.isValidJSONObject(json)
        
        let myURL = NSURL(string: "http://hayageek.com/examples/jquery/ajax-post/ajax-post.php")!
        let request = NSMutableURLRequest(url: myURL as URL)
        request.httpMethod = Constants.HTTPMethodPOST
        
        request.setValue(Constants.ContentTypeJSON, forHTTPHeaderField: Constants.ContentType)
        request.setValue(Constants.ContentTypeJSON, forHTTPHeaderField: Constants.AcceptKey)
    
        request.httpBody = data as Data
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            print(response!)
            // Your completion handler code here
            let responseString = String(data: data!, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
        }
        task.resume()
        
    }
    
    func callGetApiWithMethod(withMethod methodName: String, successHandler: @escaping (_ dictData: NSDictionary) -> Void, failureHandler: @escaping (_ strMessage: String) -> Void) {
        
        let urlString = Constants.BASEURL + methodName
        let myURL = NSURL(string: urlString)!
        let request = NSMutableURLRequest(url: myURL as URL)
        request.httpMethod = Constants.HTTPMethodGet
        
        request.setValue(Constants.ContentTypeJSON, forHTTPHeaderField: Constants.AcceptKey)
        request.setValue(Constants.ContentTypeJSON, forHTTPHeaderField: Constants.ContentType)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
//            print(response!)
            // Your completion handler code here
            let responseString = String(data: data!, encoding: .utf8)
            
            if  let dict1 = responseString?.convertToDictionary() as? NSDictionary {
                successHandler(dict1)
            } else {
                failureHandler("Some error occured")
            }
            
        }
        task.resume()
    }
    
}
