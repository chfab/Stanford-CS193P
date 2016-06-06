//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Fabrice Devos on 13/05/2016.
//  Copyright © 2016 Fabrice Devos. All rights reserved.
//

import Foundation

public extension Double {
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random:Double {
        get {
            return Double(arc4random()) / 0xFFFFFFFF
        }
    }
    /**
     Create a random number Double
     
     - parameter min: Double
     - parameter max: Double
     
     - returns: Double
     */
    public static func random(min: Double, max: Double) -> Double {
        return Double.random * (max - min) + min
    }
}

class CalculatorBrain {
    
    private var accumulator = 0.0
    private var accumulatorDescription = ""
    private var internalProgram = [AnyObject]()
    
    
    private var numberFormatter: NSNumberFormatter {
        get {
            let myNumberFormatter = NSNumberFormatter()
            myNumberFormatter.allowsFloats          = true
            myNumberFormatter.maximumFractionDigits = 6
            return myNumberFormatter
        }
    }

    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand)
        accumulatorDescription = numberFormatter.stringFromNumber(operand)!
    }
    
    private var operations:Dictionary<String, Operation> = [
        "π"    : Operation.Constant( M_PI ),
        "e"    : Operation.Constant( M_E  ),
        
        "Rand" : Operation.NoArgOperation(  { Double.random },{ "Rand()"           } ),
        
        "±"    : Operation.UnaryOperation(  { -$0 },          { "("    + $0 + ")"  } ),
        "%"    : Operation.UnaryOperation(  {  $0 / 100 },    { "("    + $0 + ")%" } ),
        "√"    : Operation.UnaryOperation(  sqrt,             { "√("   + $0 + ")"  } ),
        "∛"    : Operation.UnaryOperation(  cbrt,             { "∛("   + $0 + ")"  } ),
        "cos"  : Operation.UnaryOperation(  cos,              { "cos(" + $0 + ")"  } ),
        "sin"  : Operation.UnaryOperation(  sin,              { "sin(" + $0 + ")"  } ),
        "tan"  : Operation.UnaryOperation(  tan,              { "tan(" + $0 + ")"  } ),
        "1/x"  : Operation.UnaryOperation(  { 1 / $0 },       { "1/("  + $0 + ")"  } ),
        "10ʸ"  : Operation.UnaryOperation(  { pow(10, $0) },  { "10^(" + $0 + ")"  } ),
        "x²"   : Operation.UnaryOperation(  { pow($0,  2) },  { "("    + $0 + ")^2"} ),
        
        "xʸ"   : Operation.BinaryOperation( { pow($0, $1) },  { $0 + " ^ " + $1    } ),
        "×"    : Operation.BinaryOperation( { $0 * $1 },      { $0 + " * " + $1    } ),
        "÷"    : Operation.BinaryOperation( { $0 / $1 },      { $0 + " / " + $1    } ),
        "+"    : Operation.BinaryOperation( { $0 + $1 },      { $0 + " + " + $1    } ),
        "−"    : Operation.BinaryOperation( { $0 - $1 },      { $0 + " - " + $1    } ),
        
        "="    : Operation.Equals
    ]
    
    private enum Operation {
        case Constant(Double)
        case NoArgOperation(() -> Double, () -> String)
        case UnaryOperation((Double) -> Double, (String) -> String)
        case BinaryOperation((Double,Double) -> Double, (String, String) -> String)
        case Equals
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryOperation: (Double,Double) -> Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
 
    func performOperation(symbol: String) {
        internalProgram.append(symbol)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator            = value
                accumulatorDescription = symbol
            case .NoArgOperation(let function, let description):
                accumulatorDescription = description()
                accumulator = function()
            case .UnaryOperation(let function, let description):
                accumulatorDescription = description(accumulatorDescription)
                accumulator = function(accumulator)
            case .BinaryOperation(let function, let description):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo( binaryOperation: function, firstOperand: accumulator,
                                                      descriptionFunction: description, descriptionOperand: accumulatorDescription)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if isPartialResult {
            accumulatorDescription = pending!.descriptionFunction( pending!.descriptionOperand, accumulatorDescription)
            accumulator = pending!.binaryOperation(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    typealias PropertyList = AnyObject
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation = op as? String {
                        performOperation(operation )
                    }
                }
            }
        }
    }
    
    func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
        accumulatorDescription = ""
    }
    
    var description: String {
        get {
            if pending == nil {
                return accumulatorDescription
            } else {
                return pending!.descriptionFunction( pending!.descriptionOperand, "")
            }
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
}