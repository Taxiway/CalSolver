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
    case Equal = "="
}

class Operation {
    var type: OperationType
    var number: Int
    
    let spec = Spec()
    
    class func createOperation(text: String) -> Operation? {
        guard text.characters.count >= 1 else { return nil }
        guard let type = OperationType(rawValue: text.substring(to: text.index(after: text.startIndex))) else { return nil }
        guard let number = Int(text.substring(from: text.index(after: text.startIndex))) else { return nil }
        return Operation(type: type, num: number)
    }
    
    init(type: OperationType, num: Int) {
        self.type = type
        self.number = num
    }
    
    func operate(current: Int) -> Int? {
        switch type {
        case .Add:
            return current + number
        case .Minus:
            return current - number
        case .Multiply:
            return current * number
        case .Divide:
            if number == 0 || current % number != 0 {
                return nil
            } else {
                return current / number
            }
        default:
            return current
        }
    }
    
    func toString() -> String {
        return "  " + type.rawValue + " " + String(number) + "  "
    }
    
    func labelView() -> UILabel {
        let label = UILabel()
        label.text = toString()
        label.backgroundColor = spec.operationLabelRed
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        return label
    }
}
