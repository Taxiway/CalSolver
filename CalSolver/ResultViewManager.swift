//
//  ResultViewManager.swift
//  CalSolver
//
//  Created by Hang on 9/6/17.
//  Copyright © 2017 Hang. All rights reserved.
//

import UIKit

class ResultViewManager {
    var baseView: UIView
    var views: [UIView]
    var constraints: [NSLayoutConstraint]
    
    let spec = Spec()
    
    init(resultView: UIView) {
        self.baseView = resultView
        self.views = []
        self.constraints = []
    }
    
    func clearPreviousResult() {
        for view in views {
            view.removeFromSuperview()
        }
        views.removeAll()
        
        NSLayoutConstraint.deactivate(constraints)
        constraints.removeAll()
    }
    
    func showResult(from: Int, to: Int, operations: [Operation]) {
        clearPreviousResult()
        views.append(from.labelView())
        for operation in operations {
            views.append(operation.labelView())
        }
        views.append(Operation(type: .Equal, num: to).labelView())
        var previousView: UIView? = nil
        for view in views {
            baseView.addSubview(view)
            constraints.append(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal,
                                                  toItem: baseView, attribute: .top, multiplier: 1.0, constant: spec.horizontalMargin[1]))
            constraints.append(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: spec.rowHeight))
            if let lastView = previousView {
                constraints.append(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal,
                                                      toItem: lastView, attribute: .trailing, multiplier: 1.0, constant: spec.verticalMargin[1]))
            } else {
                constraints.append(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal,
                                                      toItem: baseView, attribute: .leading, multiplier: 1.0, constant: spec.verticalMargin[1]))
            }
            previousView = view
        }
        NSLayoutConstraint.activate(constraints)
    }
}

extension Int {
    func labelView() -> UILabel {
        let label = UILabel()
        label.text = "  " + String(self) + "  "
        label.backgroundColor = Spec().operationLabelRed
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        return label
    }
}
