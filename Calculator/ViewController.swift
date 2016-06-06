//
//  ViewController.swift
//  Calculator
//
//  Created by Fabrice Devos on 08/05/2016.
//  Copyright © 2016 Fabrice Devos. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var descriptionDisplay: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    
    private var numberFormatter: NSNumberFormatter {
        get {
            let myNumberFormatter = NSNumberFormatter()
            myNumberFormatter.allowsFloats          = true
            myNumberFormatter.maximumFractionDigits = 6
            return myNumberFormatter
        }
    }
    
    @IBAction func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if (digit != "."
            || !userIsInTheMiddleOfTyping
            || display.text!.rangeOfString(".") == nil) {
            
            if userIsInTheMiddleOfTyping {
                let valueCurrentlyDisplayed = display.text!
                display.text = valueCurrentlyDisplayed + digit
            } else {
                display.text = digit
            }
            userIsInTheMiddleOfTyping = true
        }
    }
    
    @IBAction func backspace() {
        if userIsInTheMiddleOfTyping {
            var toDisplay = display.text!
            toDisplay.removeAtIndex(display.text!.endIndex.predecessor())
            if toDisplay.characters.count == 0 {
                display.text = "0"
            } else {
                display.text = toDisplay
            }
        }
    }
    
    @IBAction func clear() {
        brain.clear()
        displayValue = nil
        descriptionDisplay.text   = " "
        userIsInTheMiddleOfTyping = false
    }
    
    // Computed property
    private var displayValue: Double? {
        get {
            return Double(display.text!)
        }
        set {
            // newValue est le mot cle qui permet de referencer la valeur passée en parametre du set
            if newValue==nil {
                display.text = "0"
            } else {
                display.text = numberFormatter.stringFromNumber(newValue!)
            }
        }
    }
    
    private var displayDescription: String {
        get {
            return descriptionDisplay.text!
        }
        set {
            if brain.isPartialResult {
                descriptionDisplay.text = newValue + " ..."
            } else {
                descriptionDisplay.text = newValue + " ="
            }
        }
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue  = brain.result
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func performCalculation(sender: UIButton) {
        if userIsInTheMiddleOfTyping && displayValue != nil {
            brain.setOperand(displayValue!)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
        displayDescription = brain.description ?? " "
    }
}