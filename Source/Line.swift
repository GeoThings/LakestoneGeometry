//
//  Line.swift
//  LakestoneGeometry
//
//  Created by Volodymyr Andriychenko on 24/10/2016.
//  Copyright © 2016 GeoThings. All rights reserved.
//
// --------------------------------------------------------
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//


#if COOPER
    import lakestonecore.android
#else
    import LakestoneCore
    import Foundation
#endif

// these are needed for math functions, java would just use Math.<function_name>
#if os(OSX) || os(iOS) || os(watchOS) || os(tvOS)
    import Darwin.C
#elseif os(Linux)
    import Glibc
#endif

// This class stores two coordinates and will be considered a line segment in most cases, but named line for simplicity and flexibility
public class Line {
    
    public var endpointA: Coordinate
    public var endpointB: Coordinate
    
    public init(endpointA: Coordinate, endpointB: Coordinate) {
        
        self.endpointA = endpointA
        self.endpointB = endpointB
        
    }
    
    //MARK: - Derived values and basic functions
    
    public var midPoint: Coordinate {
        
        let xMidPoint = (self.endpointB.x + self.endpointA.x) * 0.5
        let yMidPoint = (self.endpointB.y + self.endpointA.y) * 0.5
        
        return Coordinate(x: xMidPoint, y: yMidPoint)
    }
    
    public var squaredLength: Double {
        
        return (self.endpointB.x - self.endpointA.x) * (self.endpointB.x - self.endpointA.x) +
            (self.endpointB.y - self.endpointA.y) * (self.endpointB.y - self.endpointA.y)
    }

    
    //MARK: vector algebra
    
    ///Calculates the scalar(dot) product of the line by another one
    ///Output may be positive or negative depending on the corner between lines.
    /// - Geometrically it is a projection scaled to the length
    /// - Based on the fact that vector dot product <x1;y1> * <x2;y2> = x1*x2 + y1*y2
    /// - Note: due to roundoff the result might be nonzero even when it should be 0
    public func dotProduct (withLine secondLine: Line) -> Double {
        
        return (self.endpointB.x - self.endpointA.x) *
            (secondLine.endpointB.x - secondLine.endpointA.x) +
            (self.endpointB.y - self.endpointA.y) *
            (secondLine.endpointB.y - secondLine.endpointA.y)
    }
    
    ///Calculates the scalar(dot) product of the line by line originating from the same point
    ///having the second end at the given point
    public func dotProduct (withPoint point: Coordinate) -> Double {
        
        return dotProduct(withLine: Line(endpointA: self.endpointA, endpointB: point))
    }
    
    ///Calculates the length of the vector(cross) product of the line by another one.
    ///Output may be positive or negative depending on the lines' relative position.
    /// - Geometrically it is an area of parallelogram spanned by vectors
    /// - Based on the matrix determinant calculation <x1;y1> x <x2;y2> = x1*y2 - y1*x2
    /// - Note: due to roundoff the result might be nonzero even when it should be 0
    public func crossProduct (withLine secondLine: Line) -> Double {
        
        return (self.endpointB.x - self.endpointA.x) *
            (secondLine.endpointB.y - secondLine.endpointA.y) -
            (self.endpointB.y - self.endpointA.y) *
            (secondLine.endpointB.x - secondLine.endpointA.x)
    }
    
    ///Calculates the length of the vector(cross) product of the line by line originating
    ///from the same point having the second end at the given point
    public func crossProduct (withPoint point: Coordinate) -> Double {
        
        return crossProduct(withLine: Line(endpointA: self.endpointA, endpointB: point))
    }
    
    ///Calculate the closest distance from the given line to the point
    public func distance (toPoint point: Coordinate) -> Double {
        
        // check that line has nonzero length (no division by zero below)
        if (self.endpointA == self.endpointB) {
            
            return distanceBetween(fromPoint: self.endpointA, toPoint: point)
        }
        
        // cross product and distance times length of the line are different ways to calculate the area
        let result = self.crossProduct(withPoint: point)
        #if COOPER
        return Math.abs(result)/Math.sqrt(self.squaredLength)
        #else
        return abs(result)/sqrt(self.squaredLength)
        #endif
    }
    
    //MARK: - Boolean checks
    
    public func hasEndPoint(point: Coordinate) -> Bool {
        return (point == self.endpointA) || (point == self.endpointB)
    }
    
    ///Check if the line is parallel to another one
    /// - Returns: `true` if the segments are on the same or parallel lines
    public func isParallel (to secondLine: Line) -> Bool {
        //if vectors are parallel their cross product is zero
        return self.crossProduct(withLine: secondLine) == 0
    }
    
    //MARK: - Intersections
    
    ///Find an intersection of current line segment with another one, allowing roundoff error up to `roundoffEps`.
    /// - Returns: Coordinate if the line segments don't lie on the same or parallel lanes
    ///and the intersection point belongs to both segments, `nil` otherwise
    /// - reference: http://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
    /// - in the geometrical solution from above t and u correspond to u and v here
    public func intersection(withLine secondLine: Line) -> Coordinate? {
        
        //allow certain rounding error
        let lowerbound = -roundoffEps
        let upperbound = 1.0 + roundoffEps
        
        let crossProductValue = self.crossProduct(withLine: secondLine)
        if (crossProductValue == 0) {
            //line segments are parallel or on the same line
            return nil
        }
        
        let lineBetweenStarts = Line(endpointA: self.endpointA, endpointB: secondLine.endpointA)
        
        // u and v reflect the part of lines from start to intersection
        let u = lineBetweenStarts.crossProduct(withLine: secondLine) / crossProductValue
        let v = lineBetweenStarts.crossProduct(withLine: self) / crossProductValue

        // u within bounds means intersection is on segment self
        // v within bounds means intersection is on segment secondLine
        if (u < lowerbound || u > upperbound || v < lowerbound || v > upperbound){
            //otherwise line segments do not intersect, only lines on which they lie
            return nil
        }
        
        return Coordinate(x: self.endpointA.x + u * (self.endpointB.x - self.endpointA.x), y: self.endpointA.y + u * (self.endpointB.y - self.endpointA.y))
    }
    
    ///Find the number of intersections with BoundingBox
    /// - Note: if the line is on one of the sides of the boundingBox, the result will be 0
    public func numberofIntersections(withBox boundingBox: BoundingBox) -> Int{
        
        var number = 0
        
        for side in boundingBox.sides {
            //iterate through box sides and find all intersections
            if let point = self.intersection(withLine: side) {
                //check that intersection is counted only once
                if point != side.endpointB { number += 1 }
            }
        }
        
        return number
    }
}

//MARK: - Additional Operations

///Check if the point belongs to the line segment
/// - Note: if the point is closer than 1e-5 the function may return true
public func does(point: Coordinate, liesOnTheLine line: Line) -> Bool {
    
    #if COOPER
        let value = distanceBetween(fromPoint: line.endpointA, toPoint: point) +
            distanceBetween(fromPoint: point, toPoint: line.endpointB) - Math.sqrt(line.squaredLength)
    #else
        let value = distanceBetween(fromPoint: line.endpointA, toPoint: point) +
            distanceBetween(fromPoint: point, toPoint: line.endpointB) - sqrt(line.squaredLength)
    #endif
    //TODO: improve precision
    return (value * value <= roundoffEps)
}
