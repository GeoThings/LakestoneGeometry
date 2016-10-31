//
//  TestCoordinate.swift
//  LakestoneGeometry
//
//  Created by Volodymyr Andriychenko on 10/14/16.
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


public class TestCoordinate: Test {
    
    public func testCoordinates() {
        
        var testCoordinateInt: CoordinateInt
        var testCoordinateDouble: Coordinate
        var testDouble: Double
        
        let newInt = 4
        let newInt2 = 4
        let newDouble = 3.5
        
        //number comparison
        testCoordinateInt = CoordinateInt(x: 3, y: 5)
        testCoordinateDouble = Coordinate(x: 3.5, y: 4.5)
        
        Assert.IsTrue(newInt > testCoordinateInt.x)
        Assert.IsTrue(newInt <= testCoordinateInt.y)
        
        testCoordinateInt = CoordinateInt(x: newInt, y: newInt2)
        Assert.IsTrue(testCoordinateInt.y == testCoordinateInt.x)
        
        Assert.AreEqual(newDouble, testCoordinateDouble.x)
        Assert.IsTrue(newDouble >= testCoordinateDouble.x)
        Assert.IsTrue(newDouble < testCoordinateDouble.y)
        
        //coordinate comparison
        var testCoordinateInt2 = CoordinateInt(x: newInt, y: newInt2)
        Assert.AreEqual(testCoordinateInt, testCoordinateInt2)
        Assert.IsTrue(testCoordinateInt == testCoordinateInt2)
        
        testCoordinateInt = CoordinateInt(x: 3, y: 5)
        testCoordinateInt2 = CoordinateInt(x: 3, y: 5)
        Assert.AreEqual(testCoordinateInt, testCoordinateInt2)
        
        let testCoordinateDouble2 = Coordinate(x: newDouble, y: 4.5)
        Assert.AreEqual(testCoordinateDouble, testCoordinateDouble2)
        
        //coordinate operations
        Assert.AreEqual(distanceBetween(fromPoint: testCoordinateDouble, toPoint: testCoordinateDouble2),
                        0, Double(1e-15))
        
        testCoordinateDouble = Coordinate(x: 3.2, y: 4.1)
        Assert.AreEqual(distanceBetween(fromPoint: testCoordinateDouble, toPoint: testCoordinateDouble2),
                        0.5, Double(1e-15))
        
        testCoordinateDouble = Coordinate(x: 8, y: 0)
        testDouble = distanceBetween(fromPoint: testCoordinateDouble, toPoint: testCoordinateDouble2)
        Assert.AreEqual(testDouble * testDouble, 40.5, Double(1e-15))
        
        //description check
        Assert.IsTrue(testCoordinateInt.description.contains("3"))
        Assert.IsTrue(testCoordinateInt.description.contains("Coordinate"))
        
        Assert.IsTrue(testCoordinateDouble2.description.contains("\(newDouble)"))
        Assert.IsTrue(testCoordinateDouble2.description.contains("Coordinate"))
    }
}

#if !COOPER
    extension TestCoordinate {
        static var allTests : [(String, (TestCoordinate) -> () throws -> Void)] {
            return [
                ("testCoordinates", testCoordinates)
            ]
        }
    }
#endif
