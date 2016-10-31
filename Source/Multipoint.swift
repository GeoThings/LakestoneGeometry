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

#if COOPER
	import lakestonecore.android
#else
	import LakestoneCore
	import Foundation
#endif


public class Multipoint {
	
	//MARK: - Variables
	
	public private(set) var coordinates: [Coordinate]
	
	public private(set) var boundingBoxº: BoundingBox?
	
	public var length: Int {
		return self.coordinates.count
	}
	
	//MARK: Derived values
	
	public var isPolygon: Bool {
		
		#if COOPER
		if (self.length <= 1){
			return false
		}
		// to access values and their comparison func we need to use coordinates' array indexes
		// rather then just first and last element
		return self.coordinates[0] == self.coordinates[self.coordinates.count - 1]
			
		#else
		return (self.length > 1) && (self.coordinates.first == self.coordinates.last)
		#endif
	}
	
	//sum of areas under the edges will reduce to Shoelace formula with minus sign
	//and equals to area of the polygon, with more negative areas when polygon is counterclockwise and positive when clockwise
	//(opposite to Shoelace, thus the minus)
	//reference: https://en.wikipedia.org/wiki/Shoelace_formula
	//Note: won't be correct for self-crossing polygons
	public var signedArea: Double {
		
		if !self.isPolygon {
			return 0
		}
		var arealSum = 0.0
		
		//need to iterate through every edge and calculate the area under it (x2-x1)*[0.5*(y2+y1)]
		//alternatively can calculate 0.5*(x2*y1-x1*y2) as in Shoelace formula, which probably is slower
		for coordinateIndex in 1 ..< self.length {
			
			let lineStart = self.coordinates[coordinateIndex - 1]
			let lineEnd = self.coordinates[coordinateIndex]
			
			arealSum += (lineEnd.x - lineStart.x) * (lineEnd.y + lineStart.y) * 0.5
		}
		
		return arealSum
	}
	
	//should work for both convex and concave polygons, but for self-crossing ones detects if bigger part is clockwise
	//reference: http://stackoverflow.com/questions/1165647/how-to-determine-if-a-list-of-polygon-points-are-in-clockwise-order
	public var isClockwise: Bool {
		
		return self.signedArea > 0
	}
	
	//MARK: - Initializers
	
	public static func from(boundingBox: BoundingBox) -> Multipoint {
		
		let upperLeft = Coordinate(x: boundingBox.ll.x, y: boundingBox.ur.y)
		let upperRight = boundingBox.ur
		let lowerRight = Coordinate(x: boundingBox.ur.x, y: boundingBox.ll.y)
		let lowerLeft = boundingBox.ll
		
		return Multipoint(coordinates: [lowerLeft, upperLeft, upperRight, lowerRight, lowerLeft])
	}
	
	public init(coordinates: [Coordinate]) {
		
		self.coordinates = coordinates
		
		_initBoundingBox()
	}
	
	private func _initBoundingBox(){
		
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
		
		do {
			self.boundingBoxº = try BoundingBox(ll: Coordinate(x: minX, y: minY), ur: Coordinate(x: maxX, y: maxY)) 
		} catch {
			print("Multipoint bounding box: \(castedError(error))")
		}
	}
	
	//MARK: - Clipping and intersection functions
	
	///Clip the line part which is within the BoundingBox
	///- Note: not to confuse with poligon clip method, this returns line segments, 
	///  while the next one yields polygons
	public func polylineClipped(toBoundingBox boundingBox: BoundingBox) -> [Multipoint] {
		
		var subjectList = self.coordinates
		
		var insertionOffset = 0
		let intersectionPointsInfo = self.intesectionPoints(withBoundingBox: boundingBox)
		
		if intersectionPointsInfo.count == 0 {
			// a bit contra-intutive: don't return array containing self if no clipping done even if line segment is inside
			// so that the caller can know whether clipping was done or not
			
			return []
		}
		
		for (insertBaseIndex, intersectionPoint) in intersectionPointsInfo {
			#if COOPER
			subjectList.insert(intersectionPoint, atIndex: insertBaseIndex + insertionOffset)
			#else
			subjectList.insert(intersectionPoint, at: insertBaseIndex + insertionOffset)
			#endif
			insertionOffset += 1
		}
		
		var clippedPolylines = [Multipoint]()
		var currentPolylinePoints = [Coordinate]()
		
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
	public mutating func polygonClipped(toBoundingBox boundingBox: BoundingBox) -> [Multipoint] {
		
		if !self.isPolygon {
			return []
		}
		
		//self.makeClockwised()
		
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
		var currentPolygonPoints = [Coordinate]()
		
		var nonLinkedIntersectionCount = intersectionPointsInfo.count
		var currentIterator = subjectCircularIterator
		var isConstructingPolygon: Bool = false
		var isSearchingLinkingPoint: Bool = false
		
		var hasFinishedLinking: Bool = false
		
		while !hasFinishedLinking {
			
			guard let currentCoordinate = currentIterator.next(),
				let nextCoordinate = currentIterator.nextToReturn
				else {
					//Log.w("Clipping algorithm returned empty element during sequence iteration. Clipping or subject list is empty. Clipping cancelled.")
					return []
			}
			let currentCoordinateState = forCoordinate(currentCoordinate, relativeToClippingBox: boundingBox, isClippingList: (currentIterator === clippingCircularIterator))
			let nextCoordianteState = forCoordinate(nextCoordinate, relativeToClippingBox: boundingBox, isClippingList: (currentIterator === clippingCircularIterator))
			
			
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
				if currentCoordinateState == _IterationState.onIntersection {
					currentIterator = (currentIterator === subjectCircularIterator) ? clippingCircularIterator : subjectCircularIterator
					isSearchingLinkingPoint = true
					
					nonLinkedIntersectionCount -= 1
				}
				
			} else {
				
				//if we have found the inbound intersection that hasn't yet formed a polygon, great, let's start constructing a new polygon then
				if currentCoordinateState == _IterationState.onIntersection &&
					nextCoordianteState != _IterationState.outside &&
					!(clippedPolygons.contains { $0.coordinates.contains(currentCoordinate) }) {
					isConstructingPolygon = true
					
					currentPolygonPoints.append(currentCoordinate)
					nonLinkedIntersectionCount -= 1
				}
			}
		}
		
		return clippedPolygons
	}
	
	///Find all intersections with a bounding box
    /// - Returns: list of (index, coordinate) tuples, index starts from 1.
    /// It stores the edge number having the intersection and coordinate of the intersection point
	public func intesectionPoints(withBoundingBox boundingBox: BoundingBox) -> [(Int, Coordinate)] {
		
		if self.length < 2 {
			return []
		}
		
		var ignoreFirstPointFlag: Bool = false
		var intersectionPoints = [(Int, Coordinate)]()
		for coordinateIndex in 1 ..< self.length  {
			//iterate through sides of the polyline or polygon
			let polyEdgeStart = self.coordinates[coordinateIndex - 1]
			let polyEdgeEnd = self.coordinates[coordinateIndex]
			let polyEdge = Line(endpointA: polyEdgeStart, endpointB: polyEdgeEnd)
			
			var remainingIntersections = polyEdge.numberofIntersections(withBox: boundingBox)
			
			var lineIntersections = [Coordinate]()
			for boundingBoxSide in boundingBox.sides {
				//iterate through sides of the bounding box
				//find the intersection of the current side of the BoundingBox with the edge of polygon/polyline
				if let intersectionPoint = boundingBoxSide.intersection(withLine: polyEdge){
                    //check that intersection at the first coordinate of the Multipoint isn't counted twice
					if (intersectionPoint == self.coordinates.first && !ignoreFirstPointFlag){
						ignoreFirstPointFlag = true
					} else if (intersectionPoint == self.coordinates.first && ignoreFirstPointFlag){
						remainingIntersections -= 1
						break
					}
					
					lineIntersections.append(intersectionPoint)
					remainingIntersections -= 1
                    
                    //exit earlier if every intersection for the edge of Multiline already found
                    if remainingIntersections == 0 {
                        break
                    }
				}
			}
			//sort intersections along the edge from start to end
			lineIntersections.sort { (lhs: Coordinate, rhs: Coordinate) -> Bool in
				return distanceBetween(fromPoint: polyEdgeStart, toPoint: lhs) < distanceBetween(fromPoint: polyEdgeStart, toPoint: rhs)
			}
            //TODO: 1. check why the sorting doesn't work and makes duplicates in Java
            //2. handle the case when the edge lies on the bounding box side properly 
            //(currently the intersection point will be added if there is an intersection with another side)
			
			for lineIntersection in lineIntersections {
				intersectionPoints.append((coordinateIndex, lineIntersection))
			}
		}
		
		return intersectionPoints
	}
	
	//MARK: - Internal Utils
	
	public func makeClockwised(){
		
		if self.isClockwise {
			return
		}
		// requires explicit conversion to list to work with Java
		self.coordinates = [Coordinate](self.coordinates.reversed())
	}
	
	///Check if the coordinate is within the polygon enclosed by the given Multipoint.
	/// This algorithm does not care whether the polygon is traced in clockwise or counterclockwise fashion.
	/// - Parameters:
	///   - coordinate: point of type Coordinate
	/// - Note: The roundoff errors may lead to false detection when the point is very close to the edge
	/// - reference #0: http://alienryderflex.com/polygon/
	/// - reference #1: http://stackoverflow.com/a/31636218/2380455
	public func contains(coordinate: Coordinate) -> Bool {
		
		//if a multiline isn't a polygon, then it contains a point iff it is one of the set of coordinates
		if !self.isPolygon {
			return self.coordinates.contains(coordinate)
		}
		
		//make the previous vertex equal to last polygon's coordinate
		guard var pJ = self.coordinates.last else {
			return false
		}
		
		//if the input coordinate belongs to the polygon's vertices, there's no need to check intersections
		if self.coordinates.contains(coordinate) { return true }
		
		// iterate through edges and check that number of intersections on the right is odd
		var contains = false
		for pI in self.coordinates {
			// if an edge crosses a line of given point's y coordinate
			if ((pI.y >= coordinate.y) != (pJ.y >= coordinate.y)) {
				//in case if the point is on the edge counting other intersections is not necessary
				if does(point: coordinate, liesOnTheLine: Line(endpointA: pJ, endpointB: pI)) {
					return true
				} else {
					//check if coordinate is on the left from the line through pJ-pI or on it
					//by checking cross product against zero depending on upward or downward direction of pJ-pI
					if (coordinate.x <= (pJ.x - pI.x) * (coordinate.y - pI.y) / (pJ.y - pI.y) + pI.x) {
						contains = !contains
					}
				}
			}
			// pick the next point
			pJ = pI
		}
		
		return contains
	}
	
	//MARK: enum and state switching function
	//currently needed only for clipping function
	
	private enum _IterationState {
		case outside
		case onIntersection
		case inside
	}
	
	private static func forCoordinate(_ coordinate: Coordinate, relativeToClippingBox boundingBox: BoundingBox, isClippingList: Bool) -> _IterationState {
		
		var state: _IterationState
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
