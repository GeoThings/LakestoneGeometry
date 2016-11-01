//
//  TestUtilityFunctions.swift
//  LakestoneGeometry
//
//  Created by Volodymyr Andriychenko on 26/10/2016.
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

public class TestUtilityFuncs: Test {
    public func testUtilityOperations() {
        
        //this is test update
        Assert.AreEqual(roundoffEps, Double(1e-25), Double(1e-30))

    }
}

#if !COOPER
    extension TestUtilityFuncs {
        static var allTests : [(String, (TestUtilityFuncs) -> () throws -> Void)] {
            return [
                ("testUtilityOperations", testUtilityOperations)
            ]
        }
    }
#endif
