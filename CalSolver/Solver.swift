//
//  Solver.swift
//  CalSolver
//
//  Created by Hang on 9/6/17.
//  Copyright © 2017 Hang. All rights reserved.
//

import UIKit

class Solver {
    let maxDepth = 10
    
    func generateOperations(operations: [Operation], indices: [Int]) -> [Operation] {
        var result: [Operation] = []
        for index in indices {
            result.append(operations[index])
        }
        return result
    }
    
    func solve(from: Int, to: Int, operations: [Operation]) -> [Operation]? {
        var map = Dictionary<Int, [Int]>()
        map[from] = []
        
        var queue = [from]
        while !queue.isEmpty {
            let now = queue[0]
            var steps = map[now]!
            
            // Quit method if we are too deep and find no solution.
            // There should be something wrong in the input
            if steps.count > maxDepth {
                return nil
            }
            
            queue.remove(at: 0)
            
            for (index, operation) in operations.enumerated() {
                if let next = operation.operate(current: now) {
                    steps.append(index)
                    if next == to {
                        return generateOperations(operations: operations, indices: steps)
                    }
                    if map[next] == nil {
                        map[next] = steps
                        queue.append(next)
                    }
                    steps.remove(at: steps.count - 1)
                }
            }
        }
        return nil
    }
}
