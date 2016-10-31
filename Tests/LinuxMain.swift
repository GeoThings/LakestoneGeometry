import XCTest
@testable import LakestoneGeometryTests

XCTMain([
    testCase(TestCoordinate.allTests),
    testCase(TestBoundingBox.allTests),
    testCase(TestLine.allTests),
    testCase(TestUtilityFuncs.allTests),
    testCase(TestMultiPoint.allTests)
])
