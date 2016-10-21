//
//  TestBoundingBox.swift
//  LakestoneGeometry
//
//  Created by Volodymyr Andriychenko on 21/10/2016.
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

public class TestBoundingBox: Test {
    
    public func testBoundingBoxes() {
        
        var testCoordinateInt1: CoordinateInt
        var testCoordinateInt2: CoordinateInt
        var testCoordinateInt3: CoordinateInt
        var testCoordinateDouble1: Coordinate
        var testCoordinateDouble2: Coordinate
        var testCoordinateDouble3: Coordinate
        
        do {
            
            var testBoundingBoxInt1: BoundingBoxInt
            var testBoundingBoxInt2: BoundingBoxInt
            var testBoundingBoxDouble1: BoundingBox
            var testBoundingBoxDouble2: BoundingBox
            
            //MARK: - coordinate comparison
            testCoordinateInt1 = CoordinateInt(x: 1, y: 1)
            testCoordinateInt2 = CoordinateInt(x: 5, y: 3)
            testBoundingBoxInt1 = try BoundingBoxInt(ll: testCoordinateInt1, ur: testCoordinateInt2)
            testBoundingBoxInt2 = try BoundingBoxInt(ll: CoordinateInt(x: 1, y: 1), ur: CoordinateInt(x: 5, y: 3))
            Assert.AreEqual(testBoundingBoxInt1, testBoundingBoxInt2)
            Assert.IsTrue(testBoundingBoxInt1 == testBoundingBoxInt2)
            
            testCoordinateInt1 = CoordinateInt(x: 3, y: 5)
            testCoordinateInt2 = CoordinateInt(x: 3, y: 5)
            testBoundingBoxInt1 = try BoundingBoxInt(ll: testCoordinateInt1, ur: CoordinateInt(x: 3, y: 5))
            testBoundingBoxInt2 = try BoundingBoxInt(ll: CoordinateInt(x: 3, y: 5), ur: testCoordinateInt2)
            Assert.AreEqual(testBoundingBoxInt1, testBoundingBoxInt2)
            
            testCoordinateDouble1 = Coordinate(x: 1.0, y: 1.0)
            testCoordinateDouble2 = Coordinate(x: 5.0, y: 3.0)
            testBoundingBoxDouble1 = try BoundingBox(ll: testCoordinateDouble1, ur: testCoordinateDouble2)
            testBoundingBoxDouble2 = try BoundingBox(ll: Coordinate(x: 1, y: 1), ur: Coordinate(x: 5, y: 3))
            Assert.AreEqual(testBoundingBoxDouble1, testBoundingBoxDouble2)
            Assert.IsTrue(testBoundingBoxDouble1 == testBoundingBoxDouble2)
            
            //MARK: - check coordinate position regarding the BoundingBox
            
            //MARK: Case1: Coordinate inside the box
            
            testCoordinateInt1 = CoordinateInt(x: 1, y: 1)
            testCoordinateInt2 = CoordinateInt(x: 5, y: 3)
            testCoordinateInt3 = CoordinateInt(x: 2, y: 2)
            testBoundingBoxInt1 = try BoundingBoxInt(ll: testCoordinateInt1, ur: testCoordinateInt2)
            
            Assert.IsTrue(testBoundingBoxInt1.contains(coordinate: testCoordinateInt3))
            Assert.IsFalse(does(boundingBox: testBoundingBoxInt1, edgesContain: testCoordinateInt3))
            
            testCoordinateDouble3 = Coordinate(x: 2.3, y: 1.5)
            
            Assert.IsTrue(testBoundingBoxDouble1.contains(coordinate: testCoordinateDouble3))
            Assert.IsFalse(does(boundingBox: testBoundingBoxDouble1, edgesContain: testCoordinateDouble3))
            
            //MARK: Case2: Coordinate on the box
            
            testCoordinateInt3 = CoordinateInt(x: 2, y: 3)
            
            Assert.IsTrue(testBoundingBoxInt1.contains(coordinate: testCoordinateInt3))
            Assert.IsTrue(does(boundingBox: testBoundingBoxInt1, edgesContain: testCoordinateInt3))
            
            testCoordinateDouble3 = Coordinate(x: 1, y: 1.5)
            
            Assert.IsTrue(testBoundingBoxDouble1.contains(coordinate: testCoordinateDouble3))
            Assert.IsTrue(does(boundingBox: testBoundingBoxDouble1, edgesContain: testCoordinateDouble3))
            
            //MARK: Case3: Coordinate outside the box
            
            testCoordinateInt3 = CoordinateInt(x: 2, y: 4)
            
            Assert.IsFalse(testBoundingBoxInt1.contains(coordinate: testCoordinateInt3))
            Assert.IsFalse(does(boundingBox: testBoundingBoxInt1, edgesContain: testCoordinateInt3))
            
            testCoordinateDouble3 = Coordinate(x: 5.3, y: -4.5)
            
            Assert.IsFalse(testBoundingBoxDouble1.contains(coordinate: testCoordinateDouble3))
            Assert.IsFalse(does(boundingBox: testBoundingBoxDouble1, edgesContain: testCoordinateDouble3))
            
            //MARK: - description check
            Assert.IsTrue(testBoundingBoxInt2.description.contains("3"))
            Assert.IsTrue(testBoundingBoxInt1.description.contains("BoundingBox"))
            
            Assert.IsTrue(testBoundingBoxDouble1.description.contains("\(1.0)"))
            Assert.IsTrue(testBoundingBoxDouble2.description.contains("BoundingBox"))
            
        } catch {
            Assert.Fail("BoundingBox operation test failed: \(error)")
        }
        
        
    }
}

#if !COOPER
    extension TestBoundingBox {
        static var allTests : [(String, (TestBoundingBox) -> () throws -> Void)] {
            return [
                ("testBoundingBoxes", testBoundingBoxes)
            ]
        }
    }
#endif
