//
//  GamePlay.swift
//  Game2048
//
//  Created by Sree Sai Raghava Dandu on 21/08/21.
//

import UIKit

/// A class representing the game state and game logic. Owned by GameViewController
class GamePlay: NSObject{
    let dimension: Int
    let limit: Int
    
    
//    var score: Int = 0 {
//        didSet {
//
//        }
//    }
    var score: Int = 0
    // Gameboard
    var gameboard: SquareGameboard<SquareObject>
    //Delegate
    unowned let delegate: GamePlayProtocol
    var queue: [MoveCommand]
    var timer: Timer
    //TODO: Make commands display
    let maxCommands = 100
    let queueDelay = 0.3
    
    //Init()
    init(dimension d: Int, limit l: Int, delegate: GamePlayProtocol){
        dimension = d
        limit = l
        self.delegate = delegate
        queue = [MoveCommand]()
        timer = Timer()
        gameboard = SquareGameboard(dimension: d, initialNumber: .empty)
        super.init()
    }
    
    //MARK: - FUNCTIONS
    /// Reset the game state
    func resetGame(){
        score = 0
        //set all to empty
        gameboard.setAll(to: .empty)
        queue.removeAll(keepingCapacity: true)
    }
    /// Order the game model to perform move ( as user swiped finger on screen).
    /// The queue enforces a delay of a few milliseconds between each move
    func queueMove(direction: MoveDirection,onComplete: @escaping (Bool) -> ()){
        guard queue.count <= maxCommands else {
            // Queue is wedged
            return
        }
        queue.append(MoveCommand(direction: direction, completion: onComplete))
        if !timer.isValid{
            // Timer is not running, so start event
            //TODO: timerFired(timer)
        }
    }
    
    /// Inform the GamePlay that the move delay timer fired. Once the timer fires, the game model tries to execute a single move
    /// that changes the game state
    @objc func timerFired(_: Timer){
        if queue.count == 0{
            return
        }
        // Go through the queue until a vaild commandis run or the queue is empty
        var changed = false
        while queue.count > 0 {
            let command = queue[0]
            queue.remove(at: 0)
            changed = true
            //changed = true -- performMove
            command.completion(changed)
            if changed{
                //If the command doesn't change anything, immediately run the next one
                break
            }
        }
        if changed{
            timer = Timer.scheduledTimer(
                timeInterval: queueDelay,
                target: self,
                selector: #selector(GamePlay.timerFired(_:)),
                userInfo: nil,
                repeats: false)
        }
    }
    
    //MARK: - GAME LOGIC
    
    /// Insert a square with a given number at a position onto the gameboard
    func insertSquare(at location: (Int,Int), value: Int){
        let (x,y) = location
        if case .empty = gameboard[x,y]{
            gameboard[x,y] = SquareObject.square(value)
            delegate.insertSquare(at: location, withNumber: value)
        }
    }
    
    /// Insert a square with a given value at randon open position onto the gameboard
    func insertSquareAtRandomLocation(withValue value: Int){
        let openSpots = gameboardEmptySpots()
        if openSpots.isEmpty{
            //No more open spots avialable
            return
        }
        // Select a random spot and insert a new square
        let idx = Int(arc4random_uniform(UInt32(openSpots.count-1)))
        let (x,y) = openSpots[idx]
        insertSquare(at: (x,y), value: value)
    }
    
    /// Return a list of tuples containing the cordinates of empty spots remaing on the gameboard
    func gameboardEmptySpots() -> [(Int,Int)]{
        var temp : [(Int,Int)] = []
        for i in 0..<dimension{
            for j in 0..<dimension{
                if case .empty = gameboard[i,j]{
                    temp += [(i,j)]
                }
            }
        }
        return temp
    }
}
