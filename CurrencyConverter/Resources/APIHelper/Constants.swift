//
//  Constants.swift
//  APIHelper
//
//  Created by Chandra Rao on 12/09/17.
//  Copyright © 2017 Chandra Rao. All rights reserved.
//

import Foundation

class Constants {
 

    //Please change the URLS
    static let BASEURL = "http://api.evp.lt/currency/commercial/exchange/"
    static let HTTPMethodGet = "GET"
    static let HTTPMethodPOST = "POST"
    static let ContentType = "Content-Type"
    static let AuthorisationKey = "Authorization"
    static let AcceptKey = "Accept"
    static let ContentTypeURLEncoded = "application/x-www-form-urlencoded; charset=utf-8"
    static let ContentTypeJSON = "application/json"
    
    //API keys
    static let CurrencyKey = "currency"
    static let AmountKey = "amount"
    
    //Alet Messages
    static let AlertTitle = "Alert!"
    static let InsuffientFunds = "Transanction could be completed due to insufficient funds."
    static let SameCurrency = "Same Currency Could not be Converted."
    static let EnterAmount = "Please enter an Amount to be Converted."
    static let EnterValidAmount = "Please enter an Valid Amount to be Converted."

}
