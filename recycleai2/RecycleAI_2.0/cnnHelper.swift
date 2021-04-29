//
//  cnnHelper.swift
//  RecycleAI_2.0
//
//  Created by Maylin van Cleef on 4/27/21.
//

import Foundation
import CoreML

//Code for handling model output

extension MLMultiArray {
    /// All values will be stored in the last dimension of the MLMultiArray (default is dims=1)
        static func from(_ arr: [Int], dims: Int = 1) -> MLMultiArray {
            var shape = Array(repeating: 1, count: dims)
            shape[shape.count - 1] = arr.count
            /// Examples:
            /// dims=1 : [arr.count]
            /// dims=2 : [1, arr.count]
            ///
            let o = try! MLMultiArray(shape: shape as [NSNumber], dataType: .int32)
            let ptr = UnsafeMutablePointer<Int32>(OpaquePointer(o.dataPointer))
            for (i, item) in arr.enumerated() {
                ptr[i] = Int32(item)
            }
            return o
        }

    /// This will concatenate all dimensions into one one-dim array.
    static func toIntArray(_ o: MLMultiArray) -> [Int] {
            var arr = Array(repeating: 0, count: o.count)
            let ptr = UnsafeMutablePointer<Int32>(OpaquePointer(o.dataPointer))
            for i in 0..<o.count {
                arr[i] = Int(ptr[i])
            }
            return arr
        }


    /// This will concatenate all dimensions into one one-dim array.
    static func toDoubleArray(_ o: MLMultiArray) -> [Double] {
            var arr: [Double] = Array(repeating: 0, count: o.count)
            let ptr = UnsafeMutablePointer<Double>(OpaquePointer(o.dataPointer))
            for i in 0..<o.count {
                arr[i] = Double(ptr[i])
            }
            return arr
        }

    /// Helper to construct a sequentially-indexed multi array,
    /// useful for debugging and unit tests
    /// Example in 3 dimensions:
    /// ```
    /// [[[ 0, 1, 2, 3 ],
    ///   [ 4, 5, 6, 7 ],
    ///   [ 8, 9, 10, 11 ]],
    ///  [[ 12, 13, 14, 15 ],
    ///   [ 16, 17, 18, 19 ],
    ///   [ 20, 21, 22, 23 ]]]
    /// ```
    func testTensor(shape: [Int]) -> MLMultiArray {
            let arr = try! MLMultiArray(shape: shape as [NSNumber], dataType: .double)
            let ptr = UnsafeMutablePointer<Double>(OpaquePointer(arr.dataPointer))
            for i in 0..<arr.count {
                ptr.advanced(by: i).pointee = Double(i)
            }
        return arr
    }
    
    
    
}

func argmax(_ input: MLMultiArray, start: Int, stop: Int) -> (maxIndex: Int, maxValue: Float) {
    var maxValue = input[start].floatValue
    var maxIndex = -1

    for index in start..<stop {
        let value = input[index].floatValue
        if value >= maxValue {
            maxValue = value
            maxIndex = index
        }
    }

    return (maxIndex, maxValue)
}

/*
extension Array where Element: Comparable {
   func argmax() -> Index? {
       return indices.max(by: { self[$0] < self[$1] })
   }
   
   func argmin() -> Index? {
       return indices.min(by: { self[$0] < self[$1] })
   }
}
 */

/*
struct Math {
    
    /**
     Returns the index and value of the largest element in the array.
     
     - Parameters:
     - ptr: Pointer to the first element in memory.
     - count: How many elements to look at.
     - stride: The distance between two elements in memory.
     */
    
    /// MLMultiArray helper.
    /// Works in our specific use case.
    static func argmax(_ multiArray: MLMultiArray) -> (Int, Double) {
        assert(multiArray.dataType == .double)
        let ptr = UnsafeMutablePointer<Double>(OpaquePointer(multiArray.dataPointer))
        return Math.argmax(ptr, count: multiArray.count)
    }
    
  */
    /// Top-K.
    /// Select the k most-probable elements indices from `arr`
    /// and return both the indices (from the original array)
    /// and their softmaxed probabilities.
    ///
    
//}
