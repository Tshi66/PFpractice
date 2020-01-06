//
//  MoneyValidationRule.swift
//  PFpractice
//
//  Created by 渡辺崇博 on 2019/12/27.
//  Copyright © 2019 渡辺崇博. All rights reserved.
//

import Foundation
import Validator

/**
 Validation rule for userId.
 */
public struct ValidationRuleUserId: ValidationRule {
    public typealias InputType = String
    public var error: Error
    public let lengthRule: ValidationRuleLength
    public let patternRule: ValidationRulePattern
    public init(error: Error) {
        self.error = error
        self.lengthRule = ValidationRuleLength(min: 0, max: 16, error: self.error)
        self.patternRule =
            ValidationRulePattern(pattern: CharacterTypeValidationPattern.alphaNumeric, error: self.error)
    }
    /**

     Validates the input.

     - Parameters:
     - input: Input to validate.

     - Returns:
     true: valid, false: inValid

     */
    public func validate(input: String?) -> Bool {
        return self.lengthRule.validate(input: input) && self.patternRule.validate(input: input)
    }
}
