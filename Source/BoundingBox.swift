//
//  BoundingBox.swift
//  LakestoneGeometry
//
//  Created by Volodymyr Andriychenko on 20/10/2016.
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

//MARK: - BoundingBox rectangle with Coordinates using Double type

/// Structure to store two Coordinates defining a region
public class BoundingBox {
	
	public var ll: Coordinate
	public var ur: Coordinate
	
	public init(ll: Coordinate, ur: Coordinate) throws {
		
		if (ll.x > ur.x) || (ll.y > ur.y) {
			throw Error.InvalidCoordinates
		}
		
		self.ll = ll
		self.ur = ur
	}
	
	/// Checks if Coordinate is within or on the borders if given BoundingBox
	public func contains(coordinate: Coordinate) -> Bool {
		
		if (self.ll.x <= coordinate.x && coordinate.x <= self.ur.x &&
			self.ll.y <= coordinate.y && coordinate.y <= self.ur.y){
			return true
		} else {
			return false
		}
		
	}
}

/// checks if the Coordinate lies on the borders if given BoundingBox
public func does(boundingBox: BoundingBox, edgesContain coordinate: Coordinate) -> Bool {
	
	if ((boundingBox.ll.x == coordinate.x || boundingBox.ur.x == coordinate.x) && (boundingBox.ll.y <= coordinate.y && coordinate.y <= boundingBox.ur.y)) ||
		((boundingBox.ll.y == coordinate.y || boundingBox.ur.y == coordinate.y) && (boundingBox.ll.x < coordinate.x && coordinate.x < boundingBox.ur.x)){
		return true
	} else {
		return false
	}
}

//MARK: CustomStringConvertable
extension BoundingBox: CustomStringConvertible {
	
	public var description: String {
		return "BoundingBox: { left: \(self.ll.x), bottom: \(self.ll.y), right: \(self.ur.x), top: \(self.ur.y) }"
	}
	
	#if COOPER
	public override func toString() -> String {
		return self.description
	}
	#endif
}

//MARK: Java's Equatable analogue
extension BoundingBox: Equatable {
	
	#if COOPER
	public override func equals(_ o: Object!) -> Bool {
		
		guard let other = o as? Self else {
			return false
		}
		
		return (self == other)
	}
	#endif
	
}

public func ==(lhs: BoundingBox, rhs: BoundingBox) -> Bool {
	return (lhs.ll == rhs.ll && lhs.ur == rhs.ur)
}

//MARK: Errors
extension BoundingBox {
	
	public class Error {
		public static let InvalidCoordinates = LakestoneError.with(stringRepresentation: "BoundingBox creation failed. Please check the order of coordinates")
	}
}


//-----------------------------------------------------------------------------------

//MARK: - BoundingBox rectangle with Coordinates using Int type

/// Structure to store two Int Coordinates defining a region
public class BoundingBoxInt {
	
	public var ll: CoordinateInt
	public var ur: CoordinateInt
	
	public init(ll: CoordinateInt, ur: CoordinateInt) throws {
		
		if (ll.x > ur.x) || (ll.y > ur.y) {
			throw Error.InvalidIntCoordinates
		}
		
		self.ll = ll
		self.ur = ur
	}
	
	public func contains(coordinate: CoordinateInt) -> Bool {
		
		if (self.ll.x <= coordinate.x && coordinate.x <= self.ur.x &&
			self.ll.y <= coordinate.y && coordinate.y <= self.ur.y){
			return true
		} else {
			return false
		}
		
	}
}

/// checks if the CoordinateInt lies on the borders if given BoundingBoxInt
public func does(boundingBox: BoundingBoxInt, edgesContain coordinate: CoordinateInt) -> Bool {
	
	if ((boundingBox.ll.x == coordinate.x || boundingBox.ur.x == coordinate.x) && (boundingBox.ll.y <= coordinate.y && coordinate.y <= boundingBox.ur.y)) ||
		((boundingBox.ll.y == coordinate.y || boundingBox.ur.y == coordinate.y) && (boundingBox.ll.x < coordinate.x && coordinate.x < boundingBox.ur.x)){
		return true
	} else {
		return false
	}
}

//MARK: CustomStringConvertable
extension BoundingBoxInt: CustomStringConvertible {
	
	public var description: String {
		return "BoundingBoxInt: { left: \(self.ll.x), bottom: \(self.ll.y), right: \(self.ur.x), top: \(self.ur.y) }"
	}
	
	#if COOPER
	public override func toString() -> String {
	return self.description
	}
	#endif
}

//MARK: Java's Equatable analogue
extension BoundingBoxInt: Equatable {
	
	#if COOPER
	public override func equals(_ o: Object!) -> Bool {
	
	guard let other = o as? Self else {
	return false
	}
	
	return (self == other)
	}
	#endif
	
}

public func ==(lhs: BoundingBoxInt, rhs: BoundingBoxInt) -> Bool {
	return (lhs.ll == rhs.ll && lhs.ur == rhs.ur)
}

//MARK: Errors
extension BoundingBoxInt {
	
	public class Error {
		public static let InvalidIntCoordinates = LakestoneError.with(stringRepresentation: "BoundingBoxInt creation failed. Please check the order of coordinates")
	}
}
