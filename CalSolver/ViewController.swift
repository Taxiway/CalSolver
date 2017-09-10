//
//  ViewController.swift
//  CalSolver
//
//  Created by Hang on 9/5/17.
//  Copyright © 2017 Hang. All rights reserved.
//

import UIKit

struct Spec {
    var topMargin: CGFloat = 50.0
    var verticalMargin: [CGFloat] = [32.0, 16.0]
    var horizontalMargin: [CGFloat] = [32.0, 16.0]
    var backgroundGray: UIColor = UIColor(white: 0.9, alpha: 1.0)
    var backgroundBlue: UIColor = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 1.0, alpha: 0.3)
    var textFiledBackgoundYellow: UIColor = .yellow
    var operationLabelRed: UIColor = UIColor(colorLiteralRed: 1.0, green: 0.8, blue: 0.8, alpha: 0.3)
    var rowHeight: CGFloat = 28.0
    var textFieldWidth: CGFloat = 64.0
    var buttonHorizontalInset: CGFloat = 10.0
    
    func groupHeight(_ rows: Int) -> CGFloat {
        return verticalMargin[1] * CGFloat(rows + 1) + rowHeight * CGFloat(rows)
    }
}

protocol SolverHandler {
    func solve()
    func show(_ vc: UIViewController, sender: Any?)
}

class ViewController: UIViewController, SolverHandler {
    
    var titleLabel: UILabel!
    var fromToView: UIView!
    var operationView: UIView!
    var startButton: UIButton!
    var outputView: UIView!
    
    var fromTextField: UITextField!
    var toTextField: UITextField!
    let spec = Spec()
    let solver = Solver()
    var operationManager: OperationViewManager!
    var resultManager: ResultViewManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupViewConstraints()
    }
    
    func setupFromToView() {
        let fromLabel = UILabel()
        fromLabel.text = "From"
        fromLabel.sizeToFit()
        fromLabel.translatesAutoresizingMaskIntoConstraints = false
        fromToView.addSubview(fromLabel)
        
        let toLabel = UILabel()
        toLabel.text = "To"
        toLabel.sizeToFit()
        toLabel.translatesAutoresizingMaskIntoConstraints = false
        fromToView.addSubview(toLabel)
        
        fromTextField = UITextField()
        fromTextField.backgroundColor = spec.textFiledBackgoundYellow
        fromTextField.translatesAutoresizingMaskIntoConstraints = false
        fromTextField.becomeFirstResponder()
        fromTextField.delegate = self
        fromToView.addSubview(fromTextField)
        
        toTextField = UITextField()
        toTextField.backgroundColor = spec.textFiledBackgoundYellow
        toTextField.translatesAutoresizingMaskIntoConstraints = false
        toTextField.delegate = self
        fromToView.addSubview(toTextField)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: fromLabel, attribute: .top, relatedBy: .equal,
                                              toItem: fromToView, attribute: .top, multiplier: 1.0, constant: spec.verticalMargin[1]))
        constraints.append(NSLayoutConstraint(item: fromLabel, attribute: .trailing, relatedBy: .equal,
                                              toItem: fromToView, attribute: .centerX, multiplier: 1.0, constant: -spec.horizontalMargin[1] / 2.0))
        constraints.append(NSLayoutConstraint(item: fromLabel, attribute: .height, relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: spec.rowHeight))
        
        constraints.append(NSLayoutConstraint(item: toLabel, attribute: .top, relatedBy: .equal,
                                              toItem: fromLabel, attribute: .bottom, multiplier: 1.0, constant: spec.verticalMargin[1]))
        constraints.append(NSLayoutConstraint(item: toLabel, attribute: .trailing, relatedBy: .equal,
                                              toItem: fromToView, attribute: .centerX, multiplier: 1.0, constant: -spec.horizontalMargin[1] / 2.0))
        constraints.append(NSLayoutConstraint(item: toLabel, attribute: .height, relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: spec.rowHeight))
        
        constraints.append(NSLayoutConstraint(item: fromTextField, attribute: .top, relatedBy: .equal,
                                              toItem: fromToView, attribute: .top, multiplier: 1.0, constant: spec.verticalMargin[1]))
        constraints.append(NSLayoutConstraint(item: fromTextField, attribute: .leading, relatedBy: .equal,
                                              toItem: fromToView, attribute: .centerX, multiplier: 1.0, constant: spec.horizontalMargin[1] / 2.0))
        constraints.append(NSLayoutConstraint(item: fromTextField, attribute: .height, relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: spec.rowHeight))
        constraints.append(NSLayoutConstraint(item: fromTextField, attribute: .width, relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: spec.textFieldWidth))
        
        constraints.append(NSLayoutConstraint(item: toTextField, attribute: .top, relatedBy: .equal,
                                              toItem: fromTextField, attribute: .bottom, multiplier: 1.0, constant: spec.verticalMargin[1]))
        constraints.append(NSLayoutConstraint(item: toTextField, attribute: .leading, relatedBy: .equal,
                                              toItem: fromToView, attribute: .centerX, multiplier: 1.0, constant: spec.horizontalMargin[1] / 2.0))
        constraints.append(NSLayoutConstraint(item: toTextField, attribute: .height, relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: spec.rowHeight))
        constraints.append(NSLayoutConstraint(item: toTextField, attribute: .width, relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: spec.textFieldWidth))
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupViews() {
        titleLabel = UILabel(frame: .zero)
        titleLabel.text = "Calculate Solver"
        titleLabel.sizeToFit()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        fromToView = UIView(frame: .zero)
        fromToView.backgroundColor = spec.backgroundGray
        fromToView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fromToView)
        setupFromToView()
        
        operationView = UIView(frame: .zero)
        operationView.backgroundColor = spec.backgroundGray
        operationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(operationView)
        
        operationManager = OperationViewManager(operationView: operationView)
        operationManager.delegate = self
        
        startButton = UIButton(type: .system)
        startButton.setTitle("Start Calculation", for: .normal)
        startButton.layer.cornerRadius = 4.0
        startButton.clipsToBounds = true
        startButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: spec.buttonHorizontalInset, bottom: 0.0, right: spec.buttonHorizontalInset)
        startButton.sizeToFit()
        startButton.backgroundColor = spec.backgroundGray
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.addTarget(self, action: #selector(self.solve), for: .touchUpInside)
        view.addSubview(startButton)
        
        outputView = UIView(frame: .zero)
        outputView.backgroundColor = spec.backgroundGray
        outputView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(outputView)
        
        resultManager = ResultViewManager(resultView: outputView)
    }
    
    func setupViewConstraints() {
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal,
                                              toItem: view, attribute: .top, multiplier: 1.0, constant: spec.topMargin))
        constraints.append(NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal,
                                              toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: spec.rowHeight))
        
        constraints.append(NSLayoutConstraint(item: fromToView, attribute: .top, relatedBy: .equal,
                                              toItem: titleLabel, attribute: .bottom, multiplier: 1.0, constant: spec.verticalMargin[0]))
        constraints.append(NSLayoutConstraint(item: fromToView, attribute: .leading, relatedBy: .equal,
                                              toItem: view, attribute: .leading, multiplier: 1.0, constant: spec.horizontalMargin[0]))
        constraints.append(NSLayoutConstraint(item: fromToView, attribute: .trailing, relatedBy: .equal,
                                              toItem: view, attribute: .trailing, multiplier: 1.0, constant: -spec.horizontalMargin[0]))
        constraints.append(NSLayoutConstraint(item: fromToView, attribute: .height, relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: spec.groupHeight(2)))
        
        
        constraints.append(NSLayoutConstraint(item: operationView, attribute: .top, relatedBy: .equal,
                                              toItem: fromToView, attribute: .bottom, multiplier: 1.0, constant: spec.verticalMargin[0]))
        constraints.append(NSLayoutConstraint(item: operationView, attribute: .leading, relatedBy: .equal,
                                              toItem: view, attribute: .leading, multiplier: 1.0, constant: spec.horizontalMargin[0]))
        constraints.append(NSLayoutConstraint(item: operationView, attribute: .trailing, relatedBy: .equal,
                                              toItem: view, attribute: .trailing, multiplier: 1.0, constant: -spec.horizontalMargin[0]))
        
        constraints.append(NSLayoutConstraint(item: startButton, attribute: .top, relatedBy: .equal,
                                              toItem: operationView, attribute: .bottom, multiplier: 1.0, constant: spec.verticalMargin[0]))
        constraints.append(NSLayoutConstraint(item: startButton, attribute: .centerX, relatedBy: .equal,
                                              toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        constraints.append(NSLayoutConstraint(item: startButton, attribute: .height, relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: spec.rowHeight))
        
        constraints.append(NSLayoutConstraint(item: outputView, attribute: .top, relatedBy: .equal,
                                              toItem: startButton, attribute: .bottom, multiplier: 1.0, constant: spec.verticalMargin[0]))
        constraints.append(NSLayoutConstraint(item: outputView, attribute: .leading, relatedBy: .equal,
                                              toItem: view, attribute: .leading, multiplier: 1.0, constant: spec.horizontalMargin[0]))
        constraints.append(NSLayoutConstraint(item: outputView, attribute: .trailing, relatedBy: .equal,
                                              toItem: view, attribute: .trailing, multiplier: 1.0, constant: -spec.horizontalMargin[0]))
        constraints.append(NSLayoutConstraint(item: outputView, attribute: .height, relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: spec.groupHeight(1)))
        constraints.append(NSLayoutConstraint(item: outputView, attribute: .bottom, relatedBy: .equal,
                                              toItem: view, attribute: .bottom, multiplier: 1.0, constant: -spec.verticalMargin[0]))
        
        NSLayoutConstraint.activate(constraints)
    }

    func solve() {
        guard let from = Int(fromTextField.text ?? "") else {
            let alert = UIAlertController(title: "Invalid Input", message: "The number in \"From\" field is invalid", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.show(alert, sender: nil)
            return
        }
        guard let to = Int(toTextField.text ?? "") else {
            let alert = UIAlertController(title: "Invalid Input", message: "The number in \"From\" field is invalid", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.show(alert, sender: nil)
            return
        }
        if let sortedOperations = solver.solve(from: from, to: to, operations: operationManager.operations) {
            clearAllForNextRun()
            resultManager.showResult(from: from, to: to, operations: sortedOperations)
        } else {
            resultManager.showError()
        }
    }
    
    func clearAllForNextRun() {
        fromTextField.text = ""
        toTextField.text = ""
        operationManager.clearAllForNextRun()
        fromTextField.becomeFirstResponder()
    }

}

extension ViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == fromTextField) {
            toTextField.becomeFirstResponder()
        } else {
            assert(textField == toTextField)
            operationManager.becomeFirstResponder()
        }
        return true
    }
}
