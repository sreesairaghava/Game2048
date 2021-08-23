//
//  GameEnums.swift
//  Game2048
//
//  Created by Sree Sai Raghava Dandu on 23/08/21.
//

import Foundation

/// An enum representing directions supported by the game model.
enum MoveDirection {
  case up, down, left, right
}

/// An enum representing a movement command issued by the view controller as the result of the user swiping.
struct MoveCommand {
  let direction : MoveDirection
  let completion : (Bool) -> ()
}

/// An enum representing a 'move order'. This is a data structure the game model uses to inform the view controller
/// which tiles on the gameboard should be moved and/or combined.
enum MoveOrder {
  case singleMoveOrder(source: Int, destination: Int, number: Int, wasMerged: Bool)
  case doubleMoveOrder(firstSource: Int, secondSource: Int, destination: Int, number: Int)
}

/// An enum representing either an empty space or a tile upon the board.
enum SquareObject {
  case empty
  case square(Int)
}

/// An enum representing an intermediate result used by the game logic when figuring out how the board should change as
/// the result of a move. ActionTokens are transformed into MoveOrders before being sent to the delegate.
enum ActionToken {
  case noAction(source: Int, number: Int)
  case move(source: Int, number: Int)
  case singleCombine(source: Int, number: Int)
  case doubleCombine(source: Int, second: Int, number: Int)

  // Get the 'value', regardless of the specific type
  func getNumber() -> Int {
    switch self {
    case let .noAction(_, v): return v
    case let .move(_, v): return v
    case let .singleCombine(_, v): return v
    case let .doubleCombine(_, _, v): return v
    }
  }
  // Get the 'source', regardless of the specific type
  func getSource() -> Int {
    switch self {
    case let .noAction(s, _): return s
    case let .move(s, _): return s
    case let .singleCombine(s, _): return s
    case let .doubleCombine(s, _, _): return s
    }
  }
}

