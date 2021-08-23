//
//  GamePlay.swift
//  Game2048
//
//  Created by Sree Sai Raghava Dandu on 21/08/21.
//

import UIKit
class GamePlay: NSObject{
    let dimension : Int
    let limit : Int

    var score : Int = 0 {
      didSet {
        delegate.scoreChanged(to: score)
      }
    }
    var gameboard: SquareGameboard<SquareObject>

    unowned let delegate : GamePlayProtocol

    var queue: [MoveCommand]
    var timer: Timer

    let maxCommands = 100
    let queueDelay = 0.3

    init(dimension d: Int, limit t: Int, delegate: GamePlayProtocol) {
      dimension = d
      limit = t
      self.delegate = delegate
      queue = [MoveCommand]()
      timer = Timer()
      gameboard = SquareGameboard(dimension: d, initialNumber: .empty)
      super.init()
    }

    
    /// Reset the game state.
    func reset() {
      score = 0
      gameboard.setAll(to: .empty)
      queue.removeAll(keepingCapacity: true)
      timer.invalidate()
    }

    /// Order the game model to perform a move (because the user swiped their finger). The queue enforces a delay of a few
    /// milliseconds between each move.
    func queueMove(direction: MoveDirection, onCompletion: @escaping (Bool) -> ()) {
      guard queue.count <= maxCommands else {
        // Queue is wedged. This should actually never happen in practice.
        return
      }
      queue.append(MoveCommand(direction: direction, completion: onCompletion))
      if !timer.isValid {
        // Timer isn't running, so fire the event immediately
        timerFired(timer)
      }
    }

    /// Inform the game model that the move delay timer fired. Once the timer fires, the game model tries to execute a
    /// single move that changes the game state.
    @objc func timerFired(_: Timer) {
      if queue.count == 0 {
        return
      }
      // Go through the queue until a valid command is run or the queue is empty
      var changed = false
      while queue.count > 0 {
        let command = queue[0]
        queue.remove(at: 0)
        changed = performMove(direction: command.direction)
        command.completion(changed)
        if changed {
          // If the command doesn't change anything, we immediately run the next one
          break
        }
      }
      if changed {
        timer = Timer.scheduledTimer(timeInterval: queueDelay,
          target: self,
          selector:
          #selector(GamePlay.timerFired(_:)),
          userInfo: nil,
          repeats: false)
      }
    }

    //------------------------------------------------------------------------------------------------------------------//
    
    /// Insert a square with a given value at a position upon the gameboard.
    func insertsquare(at location: (Int, Int), value: Int) {
      let (x, y) = location
      if case .empty = gameboard[x, y] {
        gameboard[x, y] = SquareObject.square(value)
        delegate.insertSquare(at: location, withValue: value)
      }
    }

    /// Insert a square with a given value at a random open position upon the gameboard.
    func insertsquareAtRandomLocation(withValue value: Int) {
      let openSpots = gameboardEmptySpots()
      if openSpots.isEmpty {
        // No more open spots; don't even bother
        return
      }
      // Randomly select an open spot, and put a new square there
      let idx = Int(arc4random_uniform(UInt32(openSpots.count-1)))
      let (x, y) = openSpots[idx]
      insertsquare(at: (x, y), value: value)
    }
    
    func gameboardEmptySpots() -> [(Int, Int)] {
      var buffer : [(Int, Int)] = []
      for i in 0..<dimension {
        for j in 0..<dimension {
          if case .empty = gameboard[i, j] {
            buffer += [(i, j)]
          }
        }
      }
      return buffer
    }
    
    // Perform all calculations and update state for a single move.
    func performMove(direction: MoveDirection) -> Bool {
      // Prepare the generator closure. This closure differs in behavior depending on the direction of the move. It is
      // used by the method to generate a list of squares which should be modified. Depending on the direction this list
      // may represent a single row or a single column, in either direction.
      let coordinateGenerator: (Int) -> [(Int, Int)] = { (iteration: Int) -> [(Int, Int)] in
        var buffer = Array<(Int, Int)>(repeating: (0, 0), count: self.dimension)
        for i in 0..<self.dimension {
          switch direction {
          case .up: buffer[i] = (i, iteration)
          case .down: buffer[i] = (self.dimension - i - 1, iteration)
          case .left: buffer[i] = (iteration, i)
          case .right: buffer[i] = (iteration, self.dimension - i - 1)
          }
        }
        return buffer
      }

      var atLeastOneMove = false
      for i in 0..<dimension {
        // Get the list of coords
        let coords = coordinateGenerator(i)

        // Get the corresponding list of squares
        let squares = coords.map() { (c: (Int, Int)) -> SquareObject in
          let (x, y) = c
          return self.gameboard[x, y]
        }
        // Perform the operation
        let orders = merge(squares)
        atLeastOneMove = orders.count > 0 ? true : atLeastOneMove

        // Write back the results
        for object in orders {
          switch object {
          case let MoveOrder.singleMoveOrder(s, d, v, wasMerge):
            // Perform a single-square move
            let (sx, sy) = coords[s]
            let (dx, dy) = coords[d]
            if wasMerge {
              score += v
            }
            gameboard[sx, sy] = SquareObject.empty
            gameboard[dx, dy] = SquareObject.square(v)
            delegate.moveOneSquare(from: coords[s], to: coords[d], value: v)
          case let MoveOrder.doubleMoveOrder(s1, s2, d, v):
            // Perform a simultaneous two-square move
            let (s1x, s1y) = coords[s1]
            let (s2x, s2y) = coords[s2]
            let (dx, dy) = coords[d]
            score += v
            gameboard[s1x, s1y] = SquareObject.empty
            gameboard[s2x, s2y] = SquareObject.empty
            gameboard[dx, dy] = SquareObject.square(v)
            delegate.moveTwoSquares(from: (coords[s1], coords[s2]), to: coords[d], value: v)
          }
        }
      }
      return atLeastOneMove
    }
    
    
    //------------------------------------------------------------------------------------------------------------------//

    /// When computing the effects of a move upon a row of squares, calculate and return a list of ActionTokens
    /// corresponding to any moves necessary to remove interstital space. For example, |[2][ ][ ][4]| will become
    /// |[2][4]|.
    func condense(_ group: [SquareObject]) -> [ActionToken] {
      var tokenBuffer = [ActionToken]()
      for (idx, square) in group.enumerated() {
        // Go through all the squares in 'group'. When we see a square 'out of place', create a corresponding ActionToken.
        switch square {
        case let .square(value) where tokenBuffer.count == idx:
          tokenBuffer.append(ActionToken.noAction(source: idx, number: value))
        case let .square(value):
          tokenBuffer.append(ActionToken.move(source: idx, number: value))
        default:
          break
        }
      }
      return tokenBuffer;
    }

    class func quiescentsquareStillQuiescent(inputPosition: Int, outputLength: Int, originalPosition: Int) -> Bool {
      // Return whether or not a 'NoAction' token still represents an unmoved square
      return (inputPosition == outputLength) && (originalPosition == inputPosition)
    }

    /// When computing the effects of a move upon a row of squares, calculate and return an updated list of ActionTokens
    /// corresponding to any merges that should take place. This method collapses adjacent squares of equal value, but each
    /// square can take part in at most one collapse per move. For example, |[1][1][1][2][2]| will become |[2][1][4]|.
    func collapse(_ group: [ActionToken]) -> [ActionToken] {


      var tokenBuffer = [ActionToken]()
      var skipNext = false
      for (idx, token) in group.enumerated() {
        if skipNext {
          // Prior iteration handled a merge. So skip this iteration.
          skipNext = false
          continue
        }
        switch token {
        case .singleCombine:
          assert(false, "Cannot have single combine token in input")
        case .doubleCombine:
          assert(false, "Cannot have double combine token in input")
        case let .noAction(s, v)
          where (idx < group.count-1
            && v == group[idx+1].getNumber()
            && GamePlay.quiescentsquareStillQuiescent(inputPosition: idx, outputLength: tokenBuffer.count, originalPosition: s)):
          // This square hasn't moved yet, but matches the next square. This is a single merge
          // The last square is *not* eligible for a merge
          let next = group[idx+1]
          let nv = v + group[idx+1].getNumber()
          skipNext = true
          tokenBuffer.append(ActionToken.singleCombine(source: next.getSource(), number: nv))
        case let t where (idx < group.count-1 && t.getNumber() == group[idx+1].getNumber()):
          // This square has moved, and matches the next square. This is a double merge
          // (The square may either have moved prevously, or the square might have moved as a result of a previous merge)
          // The last square is *not* eligible for a merge
          let next = group[idx+1]
          let nv = t.getNumber() + group[idx+1].getNumber()
          skipNext = true
          tokenBuffer.append(ActionToken.doubleCombine(source: t.getSource(), second: next.getSource(), number: nv))
        case let .noAction(s, v) where !GamePlay.quiescentsquareStillQuiescent(inputPosition: idx, outputLength: tokenBuffer.count, originalPosition: s):
          // A square that didn't move before has moved (first cond.), or there was a previous merge (second cond.)
          tokenBuffer.append(ActionToken.move(source: s, number: v))
        case let .noAction(s, v):
          // A square that didn't move before still hasn't moved
          tokenBuffer.append(ActionToken.noAction(source: s, number: v))
        case let .move(s, v):
          // Propagate a move
          tokenBuffer.append(ActionToken.move(source: s, number: v))
        default:
          // Don't do anything
          break
        }
      }
      return tokenBuffer
    }

    /// When computing the effects of a move upon a row of squares, take a list of ActionTokens prepared by the condense()
    /// and convert() methods and convert them into MoveOrders that can be fed back to the delegate.
    func convert(_ group: [ActionToken]) -> [MoveOrder] {
      var moveBuffer = [MoveOrder]()
      for (idx, t) in group.enumerated() {
        switch t {
        case let .move(s, v):
          moveBuffer.append(MoveOrder.singleMoveOrder(source: s, destination: idx, number: v, wasMerged: false))
        case let .singleCombine(s, v):
          moveBuffer.append(MoveOrder.singleMoveOrder(source: s, destination: idx, number: v, wasMerged: true))
            playSound()
        case let .doubleCombine(s1, s2, v):
          moveBuffer.append(MoveOrder.doubleMoveOrder(firstSource: s1, secondSource: s2, destination: idx, number: v))
            playSound()
        default:
          // Don't do anything
          break
        }
      }
      return moveBuffer
    }

    /// Given an array of squareObjects, perform a collapse and create an array of move orders.
    func merge(_ group: [SquareObject]) -> [MoveOrder] {
      // Calculation takes place in three steps:
      // 1. Calculate the moves necessary to produce the same squares, but without any interstital space.
      // 2. Take the above, and calculate the moves necessary to collapse adjacent squares of equal value.
      // 3. Take the above, and convert into MoveOrders that provide all necessary information to the delegate.
      return convert(collapse(condense(group)))
    }
  }
