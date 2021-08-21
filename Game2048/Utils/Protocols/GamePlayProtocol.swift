//
//  GamePlayProtocol.swift
//  Game2048
//
//  Created by Sree Sai Raghava Dandu on 21/08/21.
//

import Foundation

protocol GamePlayProtocol: AnyObject {
    func scoreChanged(to score: Int)
    func moveOneSquare(from: (Int,Int), to: (Int,Int), number: Int)
    func moveTwoSquare(from: ((Int,Int),(Int,Int)),to: (Int,Int),number: Int)
    func insertSquare(at location: (Int,Int),withNumber number: Int)
}
