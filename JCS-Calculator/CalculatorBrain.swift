//
//  CalculatorBrain.swift
//  JCS-Calculator
//
//  Created by James Slusser on 3/22/17.
//  Copyright © 2017 James Slusser. All rights reserved.
//

import Foundation


//func changeSign(operand: Double) -> Double {
//    return -operand
//}



/// The Model for the Calculator
struct CalculatorBrain {
    
    /// Accumulates Operands for pending operations.
    private var accumulator: Double?
    
    /// Enables a Tuple that accumulates Mathematical Operations (symbols and functions) for pending operations.
    private var accumulatorString: String?
    
    
    /// Returns whether there is a binary operation pending or not.
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
    
    /// Switches to determine and return the correct type of Mathematical Operation.
    private enum Operation {
        case constant(Double)
        case nullaryOperation(() -> Double, () -> String)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double,Double) -> Double, (String,String) -> String)
        case equals
    }
    
    /// A dictionary that returns the calculation for each Mathematical Operation, and the corresponding string to be used to display the sequence of operands in the History UIlabel
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "Rand" : Operation.nullaryOperation({Double(arc4random())/0xFFFFFFFF}, {"Rand"}),
        "√" : Operation.unaryOperation(sqrt, { "√(\($0))"   }),
        "cos" : Operation.unaryOperation(cos,{ "cos(\($0))" }),
        "sin" : Operation.unaryOperation(sin,{ "sin(\($0))" }),
        "tan" : Operation.unaryOperation(tan,{ "tan(\($0))" }),
        "±" : Operation.unaryOperation({ -$0 },{ "-\($0)" }),
        "x²" : Operation.unaryOperation({ $0 * $0 },{ "(\($0))²" }),
        "×" : Operation.binaryOperation({ $0 * $1 },{ "\($0) x \($1)" }),
        "÷" : Operation.binaryOperation({ $0 / $1 },{ "\($0) ÷ \($1)" }),
        "+" : Operation.binaryOperation({ $0 + $1 }, {"\($0) + \($1)"}),
        "−" : Operation.binaryOperation({ $0 - $1 },{ "\($0) − \($1)" }),
        "=" : Operation.equals,
        ]
    
    /// Switches to determine and perform the correct Mathermatical Operation, and add to the History.
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
                
            case .constant(let value):
                accumulator = value
                accumulatorString = symbol
                
            case .nullaryOperation(let function, let description):
                accumulator = function()
                accumulatorString = description()
                
            case .unaryOperation(let function, let descriptionFunction):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                    accumulatorString = descriptionFunction(accumulatorString!)
                }
            case .binaryOperation(let function, let descriptionFunction):
                performPendingBinaryOperation()
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!, descriptionFunction: descriptionFunction, descriptionOperand: accumulatorString!)
                    accumulator = nil
                    accumulatorString = nil
                }
            // break
            case .equals:
                performPendingBinaryOperation()
                
            }
            
        }
    }
    
    /// Performs the Pending Binary Operation
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            accumulatorString = pendingBinaryOperation!.buildDescription(with: accumulatorString!)
            pendingBinaryOperation = nil
        }
    }
    
    /// **Need good description here**
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    
    
    /// Accumulates the Operands and Operations for a (Pending) Binary Operation
    private struct PendingBinaryOperation {
        let function: (Double,Double) -> Double
        let firstOperand: Double
        
        let descriptionFunction: (String,String) -> String
        let descriptionOperand: String
        
        func perform(with secondOperand: Double) -> Double {
            return function (firstOperand, secondOperand)
        }
        func buildDescription(with secondOperand: String) -> String {
            return descriptionFunction(descriptionOperand, secondOperand)
        }
    }
    
    /// Sets the Operand for a Mathematical Operation
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.usesGroupingSeparator = false
        numberFormatter.maximumFractionDigits = Constants.numberOfDigitsAfterDecimalPoint
        accumulatorString = numberFormatter.string(from: NSNumber(value: operand))
    }
    
    /// Returns result, used for Display in the ViewController
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    /// Clears everything; the Display, History and any pending binary operations.
    mutating func clear() {
        accumulator = nil
        pendingBinaryOperation = nil
        
    }
    
    /// Returns a description of the sequence of operands and operations that led to (or is leading to if resultIsPending) what is (or "will be" if resultIsPending) showing in the display.
    var description: String? {
        get {
            if pendingBinaryOperation != nil {
                return pendingBinaryOperation!.descriptionFunction(pendingBinaryOperation!.descriptionOperand,accumulatorString ?? "")
            }else{
                return accumulatorString
            }
        }
    }
}


