//
//  OperationViewManager.swift
//  CalSolver
//
//  Created by Hang on 9/6/17.
//  Copyright © 2017 Hang. All rights reserved.
//

import UIKit

class OperationViewManager : NSObject {
    var baseView: UIView
    var addButton: UIButton
    var clearButton: UIButton
    var operatorTextField: UITextField
    
    let spec = Spec()
    var operations: [Operation]
    var operationViews: [UILabel]
    var operationViewConstraints: [NSLayoutConstraint]
    
    var currentRow: Int
    var currentTotalWidth: CGFloat
    
    init(operationView: UIView) {
        self.baseView = operationView
        self.addButton = UIButton(type: .system)
        self.clearButton = UIButton(type: .system)
        self.operatorTextField = UITextField()
        self.operations = []
        self.operationViews = []
        self.operationViewConstraints = []
        self.currentRow = 0
        self.currentTotalWidth = 0
        super.init()
        setupViews()
        setupViewConstraints()
    }
    
    func setupViews() {
        addButton.setTitle("Add Operation", for: .normal)
        addButton.layer.cornerRadius = 4.0
        addButton.clipsToBounds = true
        addButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: spec.buttonHorizontalInset, bottom: 0.0, right: spec.buttonHorizontalInset)
        addButton.sizeToFit()
        addButton.backgroundColor = spec.backgroundBlue
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(self.handleAddOperation), for: .touchUpInside)
        baseView.addSubview(addButton)
        
        clearButton.setTitle("Clear All", for: .normal)
        clearButton.layer.cornerRadius = 4.0
        clearButton.clipsToBounds = true
        clearButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: spec.buttonHorizontalInset, bottom: 0.0, right: spec.buttonHorizontalInset)
        clearButton.sizeToFit()
        clearButton.backgroundColor = spec.backgroundBlue
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.addTarget(self, action: #selector(self.handleClearOperations), for: .touchUpInside)
        baseView.addSubview(clearButton)
        
        operatorTextField.translatesAutoresizingMaskIntoConstraints = false
        operatorTextField.backgroundColor = spec.textFiledBackgoundYellow
        operatorTextField.delegate = self
        baseView.addSubview(operatorTextField)
    }
    
    func shouldStartNewRow(newLabel: UILabel) -> Bool {
        let width = newLabel.frame.size.width
        return currentTotalWidth + width + spec.horizontalMargin[1] > baseView.frame.size.width - spec.horizontalMargin[1]
    }
    
    func addConstraintsForNewLabel(newLabel: UILabel) {
        let operationCount = operations.count
        if operationCount == 1 {
            operationViewConstraints.append(NSLayoutConstraint(item: newLabel, attribute: .top, relatedBy: .equal,
                                                               toItem: baseView, attribute: .top, multiplier: 1.0, constant: spec.verticalMargin[1]))
            operationViewConstraints.append(NSLayoutConstraint(item: newLabel, attribute: .leading, relatedBy: .equal,
                                                               toItem: baseView, attribute: .leading, multiplier: 1.0, constant: spec.verticalMargin[1]))
            operationViewConstraints.append(NSLayoutConstraint(item: newLabel, attribute: .height, relatedBy: .equal,
                                                               toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: spec.rowHeight))
        } else {
            if shouldStartNewRow(newLabel: newLabel) {
                currentTotalWidth = 0
                currentRow += 1
                
                operationViewConstraints.append(NSLayoutConstraint(item: newLabel, attribute: .top, relatedBy: .equal,
                                                                   toItem: baseView, attribute: .top, multiplier: 1.0, constant: spec.verticalMargin[1] + CGFloat(currentRow) * (spec.verticalMargin[1] + spec.rowHeight)))
                operationViewConstraints.append(NSLayoutConstraint(item: newLabel, attribute: .leading, relatedBy: .equal,
                                                                   toItem: baseView, attribute: .leading, multiplier: 1.0, constant: spec.verticalMargin[1]))
                operationViewConstraints.append(NSLayoutConstraint(item: newLabel, attribute: .height, relatedBy: .equal,
                                                                   toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: spec.rowHeight))
                
            } else {
                let previousLabel = operationViews[operationCount - 2]
                operationViewConstraints.append(NSLayoutConstraint(item: newLabel, attribute: .top, relatedBy: .equal,
                                                                   toItem: previousLabel, attribute: .top, multiplier: 1.0, constant: 0))
                operationViewConstraints.append(NSLayoutConstraint(item: newLabel, attribute: .leading, relatedBy: .equal,
                                                                   toItem: previousLabel, attribute: .trailing, multiplier: 1.0, constant: spec.verticalMargin[1]))
                operationViewConstraints.append(NSLayoutConstraint(item: newLabel, attribute: .height, relatedBy: .equal,
                                                                   toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: spec.rowHeight))
            }
        }
        currentTotalWidth += (newLabel.frame.size.width + spec.verticalMargin[1])
        NSLayoutConstraint.activate(operationViewConstraints)
    }
    
    @objc func handleAddOperation() {
        guard let operationString = operatorTextField.text else { return }
        guard let operation = Operation.createOperation(text: operationString) else { return }
        
        operations.append(operation)
        let label = operation.labelView()
        operationViews.append(label)
        baseView.addSubview(label)
        
        addConstraintsForNewLabel(newLabel: label)
        
        operatorTextField.text = ""
    }
    
    @objc func handleClearOperations() {
        operations.removeAll()
        
        for view in operationViews {
            view.removeFromSuperview()
        }
        operationViews.removeAll()
        
        NSLayoutConstraint.deactivate(operationViewConstraints)
        operationViewConstraints.removeAll()
        
        currentTotalWidth = 0.0
        currentRow = 0
    }
    
    func setupViewConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(NSLayoutConstraint(item: addButton, attribute: .bottom, relatedBy: .equal,
                                              toItem: clearButton, attribute: .top, multiplier: 1.0, constant: -spec.verticalMargin[1]))
        constraints.append(NSLayoutConstraint(item: addButton, attribute: .trailing, relatedBy: .equal,
                                              toItem: baseView, attribute: .centerX, multiplier: 1.0, constant: -spec.horizontalMargin[1] / 2.0))
        constraints.append(NSLayoutConstraint(item: addButton, attribute: .height, relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: spec.rowHeight))
        
        constraints.append(NSLayoutConstraint(item: clearButton, attribute: .bottom, relatedBy: .equal,
                                              toItem: baseView, attribute: .bottom, multiplier: 1.0, constant: -spec.verticalMargin[1]))
        constraints.append(NSLayoutConstraint(item: clearButton, attribute: .top, relatedBy: .equal,
                                              toItem: addButton, attribute: .bottom, multiplier: 1.0, constant: spec.verticalMargin[1]))
        constraints.append(NSLayoutConstraint(item: clearButton, attribute: .trailing, relatedBy: .equal,
                                              toItem: baseView, attribute: .centerX, multiplier: 1.0, constant: -spec.horizontalMargin[1] / 2.0))
        constraints.append(NSLayoutConstraint(item: clearButton, attribute: .height, relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: spec.rowHeight))
        
        constraints.append(NSLayoutConstraint(item: operatorTextField, attribute: .top, relatedBy: .equal,
                                              toItem: addButton, attribute: .top, multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(item: operatorTextField, attribute: .leading, relatedBy: .equal,
                                              toItem: baseView, attribute: .centerX, multiplier: 1.0, constant: spec.horizontalMargin[1] / 2.0))
        constraints.append(NSLayoutConstraint(item: operatorTextField, attribute: .height, relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: spec.rowHeight))
        constraints.append(NSLayoutConstraint(item: operatorTextField, attribute: .width, relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: spec.textFieldWidth))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func clearAllForNextRun() {
        handleClearOperations()
        operatorTextField.text = ""
    }
}

extension OperationViewManager : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleAddOperation()
        return true
    }
}
