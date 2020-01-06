//
//  MoneyValidationPattern.swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2019/12/27.
//  Copyright © 2019 渡辺崇博. All rights reserved.
//

import Foundation
import Validator

public enum CharacterTypeValidationPattern: ValidationPattern {
    case alpha
    case alphaNumeric
    case numeric
    public var pattern: String {
        switch self {
        case .alpha: return "^[A-Za-z]+$"
        case .alphaNumeric :return "^[A-Za-z0-9]+$"
        case .numeric :return "^[0-9]+$"
        }
    }
}
