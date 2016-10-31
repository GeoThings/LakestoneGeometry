//
//  TestMultiPoint.swift
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

public class TestMultiPoint: Test {
    public func testMultipointOperations() {
        
        //counter-clockwise polygon
        let testMultipoint = Multipoint(coordinates: [Coordinate(x: 3, y: 1),
                                                      Coordinate(x: 8, y: 2),
                                                      Coordinate(x: 11, y: 1),
                                                      Coordinate(x: 11, y: 7),
                                                      Coordinate(x: 9, y: 3),
                                                      Coordinate(x: 7, y: 5),
                                                      Coordinate(x: 4, y: 3),
                                                      Coordinate(x: 5, y: 6),
                                                      Coordinate(x: 3, y: 7),
                                                      Coordinate(x: 2, y: 4),
                                                      Coordinate(x: 3, y: 1)])
        //polyline
        var testMultipoint1 = Multipoint(coordinates: [Coordinate(x: 3, y: 1),
                                                       Coordinate(x: 8, y: 2),
                                                       Coordinate(x: 11, y: 1),
                                                       Coordinate(x: 11, y: 7),
                                                       Coordinate(x: 9, y: 3)])
        
        var testCoordinate1 = Coordinate(x: 9, y: 4.5)
        //polygon from BoundingBox
        let testBoundingBox0 = try! BoundingBox(ll: Coordinate(x: 1, y: 4), ur: Coordinate(x: 5, y: 8))
        var testBoundingBox1 = try! BoundingBox(ll: Coordinate(x: 2, y: 0), ur: Coordinate(x: 8, y: 4))
        var testMultipoint2 = Multipoint.from(boundingBox: testBoundingBox0)
        
        //MARK: Variables
        
        Assert.IsNotNil(testMultipoint.boundingBoxº)
        Assert.IsNotNil(testMultipoint1.boundingBoxº)
        Assert.AreEqual(testMultipoint.boundingBoxº!.ur, testMultipoint1.boundingBoxº!.ur)
        
        Assert.AreEqual(testMultipoint.length, 11)
        Assert.AreEqual(testMultipoint1.length, 5)
        
        Assert.IsTrue(testMultipoint.isPolygon)
        Assert.IsFalse(testMultipoint1.isPolygon)
        
        Assert.AreEqual(testMultipoint.signedArea, Double(-29.5), Double(1e-15))
        Assert.AreEqual(testMultipoint1.signedArea, 0)
        
        Assert.IsFalse(testMultipoint.isClockwise)
        Assert.IsTrue(testMultipoint2.isClockwise)
        
        //MARK: intersection points
        
        var intersections = testMultipoint.intesectionPoints(withBoundingBox: testBoundingBox0)
        for point in intersections
        {
            print("edge: \(point.0) x:\(point.1.x) y:\(point.1.y)\n")
        }
        print("---\n")
        intersections = testMultipoint.intesectionPoints(withBoundingBox: testBoundingBox1)
        for point in intersections
        {
            print("edge: \(point.0) x:\(point.1.x) y:\(point.1.y)\n")
        }
        print("---\n")
        
        testBoundingBox1 = try! BoundingBox(ll: Coordinate(x: 11, y: 2), ur: Coordinate(x: 12, y: 7))
        intersections = testMultipoint.intesectionPoints(withBoundingBox: testBoundingBox1)
        for point in intersections
        {
            print("edge: \(point.0) x:\(point.1.x) y:\(point.1.y)\n")
            print()
        }
        
        //MARK: clipping
        
        //MARK: makeClockwised
        
        testMultipoint.makeClockwised()
        Assert.IsTrue(testMultipoint.isClockwise)
        
        //MARK: contains
        
        //outside
        Assert.IsFalse(testMultipoint.contains(coordinate: testCoordinate1))
        //inside
        testCoordinate1 = Coordinate(x: 7, y: 3.1354)
        Assert.IsTrue(testMultipoint.contains(coordinate: testCoordinate1))
        //outside close to border, works with at least 1e-5, otherwise the point is detected on the edge
        testCoordinate1 = Coordinate(x: 5.5 - 1e-5, y: 4)
        Assert.IsFalse(testMultipoint.contains(coordinate: testCoordinate1))
        //on the vertex
        testCoordinate1 = Coordinate(x: 2, y: 4)
        Assert.IsTrue(testMultipoint.contains(coordinate: testCoordinate1))
        //on the edge
        testCoordinate1 = Coordinate(x: 5.5, y: 4)
        Assert.IsTrue(testMultipoint.contains(coordinate: testCoordinate1))
    }
}

#if !COOPER
    extension TestMultiPoint {
        static var allTests : [(String, (TestMultiPoint) -> () throws -> Void)] {
            return [
                ("testMultipointOperations", testMultipointOperations)
            ]
        }
    }
#endif
