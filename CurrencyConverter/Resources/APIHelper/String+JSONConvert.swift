//
//  String+JSONConvert.swift
//  APIHelper
//
//  Created by Chandra Rao on 13/09/17.
//  Copyright © 2017 Chandra Rao. All rights reserved.
//

import Foundation

extension String {
    
    func convertToDictionary() -> Any? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
}
