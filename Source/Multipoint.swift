//
//  Multipoint.swift
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

/*
#if os(OSX) || os(iOS) || os(watchOS) || os(tvOS)
	import Darwin.C
#elseif os(Linux)
	import Glibc
#endif

public struct Multipoint {
	
	private enum _IterationState {
		case outside
		case onIntersection
		case inside
		
		static func forCoordinate(_ coordinate: Coordinate<Double>, relativeToClippingBox boundingBox: BoundingBox<Double>, isClippingList: Bool) -> _IterationState {
			
			var state:_IterationState
			if boundingBox.contains(coordinate: coordinate){
				state = .inside
			} else {
				state = .outside
			}
			
			if does(boundingBox: boundingBox, edgesContain: coordinate){
				state = .onIntersection
			}
			
			//corner points should be considered as .inside for clippingList rather then intersection for proper execution of below algo
			if isClippingList {
				if Multipoint.from(boundingBox: boundingBox).coordinates.contains(coordinate) {
					state = .inside
				}
			}
			
			return state
		}
	}
	
	
	public private(set) var coordinates: [Coordinate<Double>]
	
	public var length: Int {
		return self.coordinates.count
	}
	
	public var isPolygon: Bool {
		return (self.length > 0) && (self.coordinates.first == self.coordinates.last)
	}
	
	public private(set) var boundingBox: BoundingBox<Double>? = nil
	
	//reference: http://stackoverflow.com/questions/1165647/how-to-determine-if-a-list-of-polygon-points-are-in-clockwise-order
	public var isClockwise: Bool {
		
		var arealSum: Double = 0
		if !self.isPolygon {
			return false
		}
		
		//no need to repeat the starting point
		for coordinateIndex in 1 ..< self.length {
			
			let lineStart = self.coordinates[coordinateIndex - 1]
			let lineEnd = self.coordinates[coordinateIndex]
			
			arealSum += (lineEnd.x - lineStart.x) * (lineEnd.y + lineStart.y)
		}
		
		return (arealSum > 0)
	}
	
	public static func from(boundingBox: BoundingBox<Double>) -> Multipoint {
		let upperLeft = Coordinate(x: boundingBox.ll.x, y: boundingBox.ur.y)
		let upperRight = boundingBox.ur
		let lowerRight = Coordinate(x: boundingBox.ur.x, y: boundingBox.ll.y)
		let lowerLeft = boundingBox.ll
		
		return Multipoint(coordinates: [upperLeft, upperRight, lowerRight, lowerLeft, upperLeft])
	}
	
	public init(coordinates: [Coordinate<Double>]){
		self.coordinates = coordinates
		
		_initBoundingBox()
	}
	
	private mutating func _initBoundingBox(){
		
		if self.coordinates.count < 2 {
			return
		}
		
		var maxX = self.coordinates[0].x
		var maxY = self.coordinates[0].y
		var minX = self.coordinates[0].x
		var minY = self.coordinates[0].y
		for pointIndex in 1 ..< self.coordinates.count {
			let element = self.coordinates[pointIndex]
			
			if element.x > maxX {
				maxX = element.x
			}
			if element.y > maxY {
				maxY = element.y
			}
			if element.x < minX {
				minX = element.x
			}
			if element.y < minY {
				minY = element.y
			}
		}
		
		self.boundingBox = BoundingBox(ll: Coordinate(x: minX, y: minY), ur: Coordinate(x: maxX, y: maxY))
	}
	
	//not to confuse with next method, this returns line segments, whether the next one yields polygons
	public mutating func polylineClipped(toBoundingBox boundingBox: BoundingBox<Double>) -> [Multipoint] {
		
		var subjectList = self.coordinates
		
		var insertionOffset = 0
		let intersectionPointsInfo = self.intesectionPoints(withBoundingBox: boundingBox)
		
		if intersectionPointsInfo.count == 0 {
			// a bit contra-intutive: don't return array containing self if no clipping done even if line segment is inside
			// so that the caller can know whether clipping was done or not
			
			return []
		}
		
		for (insertBaseIndex, intersectionPoint) in intersectionPointsInfo {
			subjectList.insert(intersectionPoint, at: insertBaseIndex + insertionOffset)
			insertionOffset += 1
		}
		
		var clippedPolylines = [Multipoint]()
		var currentPolylinePoints = [Coordinate<Double>]()
		
		for coordinate in subjectList {
			if boundingBox.contains(coordinate: coordinate) {
				currentPolylinePoints.append(coordinate)
			} else if currentPolylinePoints.count > 0 {
				clippedPolylines.append(Multipoint(coordinates: currentPolylinePoints))
				currentPolylinePoints.removeAll()
			}
		}
		
		return clippedPolylines
	}
	
	
	//Weiler–Atherton_clipping_algorithm
	public mutating func polygonClipped(toBoundingBox boundingBox: BoundingBox<Double>) -> [Multipoint] {
		
		if !self.isPolygon {
			return []
		}
		
		self.makeClockwised()
		
		// PART 1: Forming a clipping region polygon and subject polygon list
		var clippingList = Multipoint.from(boundingBox: boundingBox).coordinates
		var subjectList = self.coordinates
		
		var insertionOffset = 0
		let intersectionPointsInfo = self.intesectionPoints(withBoundingBox: boundingBox)
		
		//no intersection, either clipping list is inside, bouding box is inside, or no intersection
		if intersectionPointsInfo.count == 0 {
			guard let subjectFirstCoordinate = self.coordinates.first,
				let clippingRegionFirstCoordinate = subjectList.first
				else {
					return []
			}
			
			if self.contains(coordinate: clippingRegionFirstCoordinate){
				return [Multipoint.from(boundingBox: boundingBox)]
			} else if boundingBox.contains(coordinate: subjectFirstCoordinate){
				// a bit contra-intutive: don't return array containing self if no clipping done even if polygon is inside
				// so that the caller can know whether clipping was done or not
				
				return []
			} else {
				return []
			}
		}
		
		for (insertBaseIndex, intersectionPoint) in intersectionPointsInfo {
			subjectList.insert(intersectionPoint, at: insertBaseIndex + insertionOffset)
			insertionOffset += 1
		}
		
		//making both lists open, since it will be later used in a circular sequence
		subjectList.removeLast()
		clippingList.removeLast()
		
		clippingList += intersectionPointsInfo.map { $0.1 }
		clippingList = coordinatesOrderedClockwise(fromCoordinates: clippingList, fromCenter: midpoint(ofLineFrom: boundingBox.ll, to: boundingBox.ur))
		
		let clippingCircularIterator = CircularSequence(elements: clippingList).makeIterator()
		let subjectCircularIterator = CircularSequence(elements: subjectList).makeIterator()
		
		// PART2: Iterating. Finding an intersection in a direction of polygon in subject list
		// As soon as we reach a next intersection we jump to another list back and force until our looping reaches the original intersection
		
		var clippedPolygons = [Multipoint]()
		var currentPolygonPoints = [Coordinate<Double>]()
		
		var nonLinkedIntersectionCount = intersectionPointsInfo.count
		var currentIterator = subjectCircularIterator
		var isConstructingPolygon: Bool = false
		var isSearchingLinkingPoint: Bool = false
		
		var hasFinishedLinking: Bool = false
		
		while !hasFinishedLinking {
			
			guard let currentCoordinate = currentIterator.next(),
				let nextCoordinate = currentIterator.nextToReturn
				else {
					Log.w("Clipping algorithm returned empty element during sequence iteration. Clipping or subject list is empty. Clipping cancelled.")
					return []
			}
			let currentCoordinateState = _IterationState.forCoordinate(currentCoordinate, relativeToClippingBox: boundingBox, isClippingList: (currentIterator === clippingCircularIterator))
			let nextCoordianteState = _IterationState.forCoordinate(nextCoordinate, relativeToClippingBox: boundingBox, isClippingList: (currentIterator === clippingCircularIterator))
			
			
			if isSearchingLinkingPoint && currentCoordinate != currentPolygonPoints.last {
				continue
			} else if isSearchingLinkingPoint && currentCoordinate == currentPolygonPoints.last {
				isSearchingLinkingPoint = false
				continue
			}
			
			if isConstructingPolygon {
				
				currentPolygonPoints.append(currentCoordinate)
				
				//if we have found the first current polygon point, complete it
				if currentPolygonPoints.first == currentCoordinate {
					clippedPolygons.append(Multipoint(coordinates: currentPolygonPoints))
					
					currentPolygonPoints.removeAll()
					isConstructingPolygon = false
					
					//if we linked all intersections, we done done, congrats
					if (nonLinkedIntersectionCount <= 0){
						hasFinishedLinking = true
					}
					continue
				}
				
				//on intersection, time to jump to next list and start searching for it
				if currentCoordinateState == .onIntersection {
					currentIterator = (currentIterator === subjectCircularIterator) ? clippingCircularIterator : subjectCircularIterator
					isSearchingLinkingPoint = true
					
					nonLinkedIntersectionCount -= 1
				}
				
			} else {
				
				//if we have found the inbound intersection that hasn't yet formed a polygon, great, let's start constructing a new polygon then
				if currentCoordinateState == .onIntersection && nextCoordianteState != .outside && !(clippedPolygons.contains { $0.coordinates.contains(currentCoordinate) }) {
					isConstructingPolygon = true
					
					currentPolygonPoints.append(currentCoordinate)
					nonLinkedIntersectionCount -= 1
				}
			}
		}
		
		return clippedPolygons
	}
	
	mutating public func makeClockwised(){
		
		if self.isClockwise {
			return
		}
		
		self.coordinates = self.coordinates.reversed()
	}
	
	public func intesectionPoints(withBoundingBox boundingBox: BoundingBox<Double>) -> [(Int, Coordinate<Double>)] {
		
		if self.length < 2 {
			return []
		}
		
		
		var ignoreFirstPointFlag: Bool = false
		var intersectionPoints = [(Int, Coordinate<Double>)]()
		for coordinateIndex in 1 ..< self.length  {
			
			let firstLineStart = self.coordinates[coordinateIndex - 1]
			let firstLineEnd = self.coordinates[coordinateIndex]
			
			var remainingIntersections = 0
			if boundingBox.contains(coordinate: firstLineStart) && boundingBox.contains(coordinate: firstLineEnd){
				//line segment insvide bounding box, no intersection
				continue
			} else if boundingBox.contains(coordinate: firstLineStart) || boundingBox.contains(coordinate: firstLineEnd){
				//one point is inside, so one point intersection
				remainingIntersections = 1
			} else {
				//both points are outside segment, 0 or 2 intersections
				remainingIntersections = 2
			}
			
			let boundingBoxCoordinates = Multipoint.from(boundingBox: boundingBox).coordinates
			
			var lineIntersections = [Coordinate<Double>]()
			for index in 1 ..< boundingBoxCoordinates.count {
				
				let lineStart = boundingBoxCoordinates[index - 1]
				let lineEnd = boundingBoxCoordinates[index]
				
				if let intersectionPoint = intersection(ofLineFrom: lineStart, to: lineEnd, withLineFrom: firstLineStart, to: firstLineEnd){
					if (intersectionPoint == self.coordinates.first && !ignoreFirstPointFlag){
						ignoreFirstPointFlag = true
					} else if (intersectionPoint == self.coordinates.first && ignoreFirstPointFlag){
						remainingIntersections -= 1
						break
					}
					
					lineIntersections.append(intersectionPoint)
					remainingIntersections -= 1
				}
				
				if remainingIntersections == 0 {
					break
				}
			}
			
			lineIntersections.sort { (lhs: Coordinate<Double>, rhs: Coordinate<Double>) -> Bool in
				return distance(fromPoint: firstLineStart, toPoint: lhs) < distance(fromPoint: firstLineStart, toPoint: rhs)
			}
			
			for lineIntersection in lineIntersections {
				intersectionPoints.append((coordinateIndex, lineIntersection))
			}
		}
		
		return intersectionPoints
	}
	
	//reference #0: http://alienryderflex.com/polygon/
	//reference #1: http://stackoverflow.com/a/31636218/2380455
	public func contains(coordinate: Coordinate<Double>) -> Bool {
		
		if !self.isPolygon {
			return self.coordinates.contains(coordinate)
		}
		
		guard var pJ = self.coordinates.last else {
			return false
		}
		
		var contains = false
		for pI in self.coordinates {
			if ( ((pI.y >= coordinate.y) != (pJ.y >= coordinate.y)) &&
				(coordinate.x <= (pJ.x - pI.x) * (coordinate.y - pI.y) / (pJ.y - pI.y) + pI.x) ){
				
				contains = !contains
			}
			
			pJ = pI
		}
		
		return contains
	}
}
*/
