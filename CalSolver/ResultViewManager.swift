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
    var errorLabel: UILabel
    var scrollView: UIScrollView
    
    let spec = Spec()
    
    init(resultView: UIView) {
        self.baseView = resultView
        self.views = []
        self.constraints = []
        
        self.errorLabel = UILabel(frame: .zero)
        errorLabel.text = "Solution not found."
        errorLabel.sizeToFit()
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func clearPreviousResult() {
        for view in views {
            view.removeFromSuperview()
        }
        views.removeAll()
        errorLabel.removeFromSuperview()
        
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
        
        baseView.addSubview(scrollView)
        constraints.append(NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal,
                                              toItem: baseView, attribute: .top, multiplier: 1.0, constant: spec.verticalMargin[1]))
        constraints.append(NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal,
                                              toItem: baseView, attribute: .bottom, multiplier: 1.0, constant: -spec.verticalMargin[1]))
        constraints.append(NSLayoutConstraint(item: scrollView, attribute: .leading, relatedBy: .equal,
                                              toItem: baseView, attribute: .leading, multiplier: 1.0, constant: spec.horizontalMargin[1]))
        constraints.append(NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal,
                                              toItem: baseView, attribute: .trailing, multiplier: 1.0, constant: -spec.horizontalMargin[1]))
        
        var previousView: UIView? = nil
        var totalWidth: CGFloat = 0.0
        for view in views {
            scrollView.addSubview(view)
            constraints.append(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal,
                                                  toItem: scrollView, attribute: .top, multiplier: 1.0, constant: 0))
            constraints.append(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: spec.rowHeight))
            if let lastView = previousView {
                constraints.append(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal,
                                                      toItem: lastView, attribute: .trailing, multiplier: 1.0, constant: spec.horizontalMargin[1]))
                totalWidth += spec.horizontalMargin[1]
            } else {
                constraints.append(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal,
                                                      toItem: scrollView, attribute: .leading, multiplier: 1.0, constant: 0))
            }
            totalWidth += view.frame.size.width
            previousView = view
        }
        
        scrollView.contentSize = CGSize(width: totalWidth, height: spec.rowHeight)
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func showError() {
        clearPreviousResult()
        baseView.addSubview(errorLabel)
        constraints.append(NSLayoutConstraint(item: errorLabel, attribute: .top, relatedBy: .equal,
                                              toItem: baseView, attribute: .top, multiplier: 1.0, constant: spec.verticalMargin[1]))
        constraints.append(NSLayoutConstraint(item: errorLabel, attribute: .centerX, relatedBy: .equal,
                                              toItem: baseView, attribute: .centerX, multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(item: errorLabel, attribute: .height, relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: spec.rowHeight))
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
