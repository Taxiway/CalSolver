//
//  Operation.swift
//  CalSolver
//
//  Created by Hang on 9/6/17.
//  Copyright © 2017 Hang. All rights reserved.
//

import UIKit

enum OperationType: String {
    case Add = "+"
    case Minus = "-"
    case Multiply = "*"
    case Divide = "/"
    case Delete = "<"
    case Append = "A"
    case Convert = ">"
    case Power = "X"
    case Reverse = "+-"
    case Equal = "="
}

class Operation {
    var type: OperationType
    var number: Int?
    var number2: Int?
    
    let spec = Spec()
    
    class func createOperation(text: String) -> Operation? {
        guard text.characters.count >= 1 else { return nil }
        if let type = OperationType(rawValue: text) {
            return Operation(type: type)
        }
        guard let type = OperationType(rawValue: text.uppercased().substring(to: text.index(after: text.startIndex))) else {
            if let number = Int(text) {
                // Append operation
                return Operation(type: .Append, num: number)
            } else {
                if let ind = text.range(of: OperationType.Convert.rawValue) {
                    guard let n1 = Int(text.substring(to: ind.lowerBound)) else { return nil }
                    guard let n2 = Int(text.substring(from: ind.upperBound)) else { return nil }
                    return Operation(type: .Convert, num: n1, num2: n2)
                } else {
                    return nil
                }
            }
        }
        if type == .Delete {
            guard text.characters.count == 1 else { return nil }
            return Operation(type: .Delete, num: nil)
        }
        guard let number = Int(text.substring(from: text.index(after: text.startIndex))) else { return nil }
        return Operation(type: type, num: number)
    }
    
    init(type: OperationType, num: Int? = nil, num2: Int? = nil) {
        self.type = type
        self.number = num
        self.number2 = num2
    }
    
    func operate(current: Int) -> Int? {
        switch type {
        case .Add:
            return current + number!
        case .Minus:
            return current - number!
        case .Multiply:
            return current * number!
        case .Divide:
            if number! == 0 || current % number! != 0 {
                return nil
            } else {
                return current / number!
            }
        case .Delete:
            return current / 10
        case .Append:
            return Int(String(current) + String(number!))
        case .Convert:
            return Int(String(current).replacingOccurrences(of: String(number!), with: String(number2!)))
        case .Power:
            var ret = 1
            for _ in 1...number! {
                ret *= current
            }
            return ret
        case .Reverse:
            return -current
        default:
            return current
        }
    }
    
    func toString() -> String {
        let opString = "  " + type.rawValue + " "
        if let number = number {
            if let number2 = number2 {
                return "  " + String(number) + opString + String(number2) + "  "
            } else {
                return opString + String(number) + "  "
            }
        } else {
            return opString + " "
        }
    }
    
    func labelView() -> UILabel {
        let label = UILabel()
        label.text = toString()
        label.backgroundColor = spec.operationLabelRed
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 4.0
        label.clipsToBounds = true
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 1.0
        label.sizeToFit()
        return label
    }
}
