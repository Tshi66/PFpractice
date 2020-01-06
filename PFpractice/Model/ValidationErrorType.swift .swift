//
//  ValidationErrorType.swift .swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2019/12/25.
//  Copyright © 2019 渡辺崇博. All rights reserved.
//

import Foundation
import Validator

struct ExampleValidationError: ValidationError {

    let message: String
    
    public init(_ message: String) {
        
        self.message = message
    }
}
