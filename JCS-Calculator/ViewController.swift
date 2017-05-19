//
//  ViewController.swift
//  JCS-Calculator
//
//  Created by James Slusser on 3/22/17.
//  Copyright © 2017 James Slusser. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            //display.text = textCurrentlyInDisplay + digit
            display.text = (digit == "." && textCurrentlyInDisplay.range(of: ".") != nil) ? textCurrentlyInDisplay : textCurrentlyInDisplay + digit
        } else {
            //display.text = digit
            display.text = (digit == ".") ? "0." : digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set{
            //display.text = String(newValue)
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.usesGroupingSeparator = false
            numberFormatter.maximumFractionDigits = Constants.numberOfDigitsAfterDecimalPoint
            display.text = numberFormatter.string(from: NSNumber(value: newValue))
        }
    }
    
    private var brain: CalculatorBrain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
            displayValue = result
        }
        if let description = brain.description {
            history.text = description + (brain.resultIsPending ? ((description.characters.last != " ") ? "..." : "...") : " =")
        }
    }
    
    @IBAction func clearAll(_ sender: UIButton) {
        //brain.clear()
        brain = CalculatorBrain()
        displayValue = 0
        history.text = " "
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            var textCurrentlyInDisplay = display.text!
            textCurrentlyInDisplay.remove(at: textCurrentlyInDisplay.index(before: textCurrentlyInDisplay.endIndex))
            if textCurrentlyInDisplay.isEmpty {
                userIsInTheMiddleOfTyping = false
                textCurrentlyInDisplay = "0"
            }
            display.text = textCurrentlyInDisplay
        }
    }
}
