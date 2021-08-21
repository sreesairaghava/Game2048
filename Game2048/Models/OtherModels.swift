//
//  OtherModels.swift
//  Game2048
//
//  Created by Sree Sai Raghava Dandu on 21/08/21.
//

import Foundation

/// Enum representing directions supported by GamePlay
enum MoveDirection{
    case up, down, left, right
}
/// Enum representing a movement command from VC as result of swiping
struct MoveCommand{
    let direction: MoveDirection
    let completion: (Bool) -> ()
}

/// Enum represnting moving order. Data structure the game model uses to inform the view controller
/// which square on the gameboard should be moved or combined
enum MoveOrder {
    case singleMoveOrder(source: Int, destination: Int, number: Int, wasMerged: Bool)
    case doubleMoveOrder(firstSource:Int, secondSource: Int, destination: Int, number: Int)
}

/// Enum representing squre either empty space or a square is available on the board
enum SquareObject {
    case empty
    case square(Int)
}

/// Enum representing an intermediate result used by the game logic when figuring out how the board should change as
/// the result of a move. ActionTokens are transformed into MoverOrders before sent to delegate
enum ActionToken {
    case noAction(source: Int, number: Int)
    case move(source: Int, number: Int)
    case singleCombine(source: Int, number: Int)
    case doubleCombine(source: Int, second: Int, number: Int)
    
    //Get the 'number' of anytype
    func getNumber() -> Int{
        switch self {
        case let .noAction(source: _, number: n): return n
        case let .move(source: _, number: n): return n
        case let .singleCombine(source: _, number: n): return n
        case let .doubleCombine(source: _, second: _, number: n): return n
        }
    }
}

/// Struct representing square gameboard. Using Generics to support resuablity
struct SquareGameboard<T> {
    let dimension: Int
    var boardArray: [T]
    
    init(dimension d: Int, initialNumber: T) {
        dimension = d
        boardArray = [T](repeating: initialNumber, count: d*d)
    }
    subscript(row: Int,col: Int) -> T{
        get{
            assert(row >= 0 && row < dimension)
            assert(col >= 0 && col < dimension)
            return boardArray[row*dimension + col]
        }
        set{
            assert(row >= 0 && row < dimension)
            assert(col >= 0 && col < dimension)
            return boardArray[row*dimension + col] = newValue
        }
    }
    //Mutating function to change parent struct
    mutating func setAll(to item: T){
        for i in 0..<dimension{
            for j in 0..<dimension{
                self[i,j] = item
            }
        }
    }
}
