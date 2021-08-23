//
//  SquareGameBoard.swift
//  Game2048
//
//  Created by Sree Sai Raghava Dandu on 23/08/21.
//

import Foundation

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
