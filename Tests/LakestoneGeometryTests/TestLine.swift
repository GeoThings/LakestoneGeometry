//
//  TestLine.swift
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
    
    import remobjects.elements.eunit
    import lakestonecore.android
    
#else
    
    import XCTest
    import Foundation
    import LakestoneCore
    
    @testable import LakestoneGeometry
    
#endif

public class TestLine: Test {
    public func testLineOperations() {

        let origin = Coordinate(x: 0, y: 0)
        var testCoordinate1: Coordinate
        var testCoordinate2: Coordinate
        var testCoordinate3: Coordinate
        var testCoordinate4: Coordinate
        var testLine1: Line
        var testLine2: Line
        var testLine3: Line
        
        //init line1
        testCoordinate1 = origin
        testCoordinate2 = Coordinate(x: 3, y: 4)
        testLine1 = Line(endpointA: testCoordinate1, endpointB: testCoordinate2)
        let length1 = testCoordinate2.x * testCoordinate2.x +
            testCoordinate2.y * testCoordinate2.y
        
        // since this line comes from origin (0;0) its squared length should be equal
        // to sum of squares of coordinates of the second endpoint
        Assert.AreEqual(length1, testLine1.squaredLength)
        
        // length of the midpoint vector should be half of the original (quarter when squared)
        testCoordinate3 = testLine1.midPoint
        testLine1 = Line(endpointA: testCoordinate1, endpointB: testCoordinate3)
        testLine2 = Line(endpointA: testCoordinate3, endpointB: testCoordinate2)
        
        Assert.AreEqual(length1, testLine1.squaredLength * 4)
        Assert.IsTrue(testLine1.squaredLength == testLine2.squaredLength)
        
        //MARK: vector funcs
        
        //current state: point3 in the middle from origin (point1) and point2
        testCoordinate4 = Coordinate(x: 6, y: 2)
        testLine3 = Line(endpointA: origin, endpointB: testCoordinate4)
        Assert.AreEqual(testLine3.dotProduct(withPoint: testCoordinate3),
                        testLine2.dotProduct(withLine: testLine3))
        Assert.AreEqual(testLine1.crossProduct(withLine: testLine3) * 2,
                        -testLine3.crossProduct(withPoint: testCoordinate2))
        Assert.AreEqual(testLine3.dotProduct(withLine: testLine3), testLine3.squaredLength)
        Assert.AreEqual(testLine3.dotProduct(withPoint: testCoordinate4), testLine3.squaredLength)
        
        testLine1 = Line(endpointA: origin,
                         endpointB: Coordinate(x: testCoordinate2.x, y: 0))
        testLine2 = Line(endpointA: origin,
                         endpointB: Coordinate(x: 0, y: testCoordinate2.y))
        Assert.AreEqual(testLine2.dotProduct(withLine: testLine1), 0)
        Assert.AreEqual(testLine1.crossProduct(withLine: testLine2), testCoordinate2.x * testCoordinate2.y)
        
        // distance check, requires some precision allowance
        // the values were calculated using http://www.wolframalpha.com, 
        // where the numbers are rounded to fifth digit, which gives the precision up to 0.5e-5
        testLine1 = Line(endpointA: Coordinate(x: -2, y: 0), endpointB: Coordinate(x: 1, y: 3))
        testCoordinate1 = Coordinate(x: 3, y: 2)
        // the distance here is 3/sqtr(2), squared should be equal to 4.5 but still differs by some very small margin
        Assert.AreEqual(testLine1.distance(toPoint: testCoordinate1) *
            testLine1.distance(toPoint: testCoordinate1), Double(4.5), Double(1e-15))
        
        testLine1 = Line(endpointA: Coordinate(x: -2, y: 0), endpointB: Coordinate(x: -1, y: 1))
        testCoordinate1 = Coordinate(x: -0.5, y: -1)
        Assert.AreEqual(testLine1.distance(toPoint: testCoordinate1), Double(1.76777), Double(0.000005))
        
        testLine1 = Line(endpointA: Coordinate(x: 0.46, y: 0), endpointB: Coordinate(x: 0.23, y: 1.15))
        testCoordinate1 = Coordinate(x: 1, y: 1)
        Assert.AreEqual(testLine1.distance(toPoint: testCoordinate1), Double(0.72563), Double(0.000005))
        
        //MARK: Bool checks
        
        // including endpoint
        Assert.IsFalse(testLine1.hasEndPoint(point: testCoordinate1))
        Assert.IsTrue(testLine2.hasEndPoint(point: origin))
        Assert.IsFalse(testLine3.hasEndPoint(point: testCoordinate3))
        
        // are parallel
        //testLine3 is still from origin to point4(6,2)
        testLine1 = Line(endpointA: Coordinate(x: 0, y: -2), endpointB: Coordinate(x: 6, y: 0))
        Assert.IsTrue(testLine1.isParallel(to: testLine3))
        
        testLine1 = Line(endpointA: origin, endpointB: Coordinate(x: 6, y: 1.9))
        Assert.IsFalse(testLine1.isParallel(to: testLine3))
        
        // in this case they're on the same line
        testLine1 = Line(endpointA: Coordinate(x: 0, y: 5), endpointB: Coordinate(x: 0, y: 10))
        Assert.IsTrue(testLine2.isParallel(to: testLine1))
        
        //MARK: intersection
        
        // the values were calculated using http://www.wolframalpha.com,
        // which in the case of given lines provides the result as fractions
        Assert.IsNil(testLine1.intersection(withLine: testLine2))
        Assert.AreEqual(testLine2.intersection(withLine: testLine3)!, origin)
        
        testLine1 = Line(endpointA: Coordinate(x: -0.1, y: 0.1), endpointB: Coordinate(x: -0.6, y: 0.6))
        testLine2 = Line(endpointA: Coordinate(x: -0.5, y: 0), endpointB: Coordinate(x: 0, y: 1))
        testCoordinate1 = testLine2.intersection(withLine: testLine1)!
        testCoordinate2 = Coordinate(x: -1.0/3.0, y: 1.0/3.0)
        Assert.AreEqual(testCoordinate1.x, testCoordinate2.x, Double(1e-15))
        Assert.AreEqual(testCoordinate1.y, testCoordinate2.y, Double(1e-15))
        
        testLine1 = Line(endpointA: Coordinate(x: 10.0/2.2, y: 0), endpointB: Coordinate(x: 0, y: 10))
        testCoordinate1 = testLine3.intersection(withLine: testLine1)!
        testCoordinate2 = Coordinate(x: 75.0/19.0, y: 25.0/19.0)
        Assert.AreEqual(testCoordinate1.x, testCoordinate2.x, Double(1e-15))
        Assert.AreEqual(testCoordinate1.y, testCoordinate2.y, Double(1e-15))
        
        //MARK: point lies on the line
        
        Assert.IsTrue(does(point: testCoordinate1, liesOnTheLine: testLine1))
        Assert.IsTrue(does(point: testCoordinate1, liesOnTheLine: testLine3))
        Assert.IsTrue(does(point: testCoordinate2, liesOnTheLine: testLine3))
        
        testCoordinate1 = Coordinate(x: 4.5, y: 1.5)
        Assert.IsTrue(does(point: testCoordinate1, liesOnTheLine: testLine3))
        
        testCoordinate1 = Coordinate(x: 5, y: 1.5)
        Assert.IsFalse(does(point: testCoordinate1, liesOnTheLine: testLine3))
    }
}

#if !COOPER
    extension TestLine {
        static var allTests : [(String, (TestLine) -> () throws -> Void)] {
            return [
                ("testLineOperations", testLineOperations)
            ]
        }
    }
#endif
