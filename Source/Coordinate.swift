//
//  Coordinate.swift
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
    import lakestonecore.android
#else
    import LakestoneCore
    import Foundation
#endif

//MARK: - Coordinate using Double type

public class Coordinate {
    
    /*! primarily designated to store longitude in degrees */
    public var x: Double
    /*! primarily designated to store latitude in degrees */
    public var y: Double
    
    public init(x: Double, y: Double){
        self.x = x
        self.y = y
    }

    // for CustomSerialization
    public required init(){
        self.x = 0
        self.y = 0
    }
    
    public required init(variableMap: [String : Any]) throws {
        
        guard let x = variableMap["x"] else { throw DictionaryInstantiationError.Representation(fieldName: "x", detail: "not found").error }
        guard let y = variableMap["y"] else { throw DictionaryInstantiationError.Representation(fieldName: "x", detail: "not found").error }
        
        self.x = x as! Double
        self.y = y as! Double
    }
}

//MARK: CustomStringConvertable
extension Coordinate: CustomStringConvertible {
    
    public var description: String {
        return "Coordinate: { long: \(self.x), lat: \(self.y) }"
    }
        
    #if COOPER
    public override func toString() -> String {
        return self.description
    }
    #endif
}

//MARK: CustomSerializable
extension Coordinate: CustomSerializable {

    public static var readingIgnoredVariableNames: Set<String> { return Set<String>() }
    public static var writingIgnoredVariableNames: Set<String> { return Set<String>() }
    
    public static var allowedTypeDifferentVariableNames: Set<String> { return Set<String>() }
    public static var variableNamesAlliases: [String: String] { return [String: String]() }
    
    public var manuallySerializedValues: [String: Any] { return [String: Any]() }
}

//MARK: Java's Equatable analogue
extension Coordinate: Equatable {
    
    #if COOPER
    public override func equals(_ o: Object!) -> Bool {
        
        guard let other = o as? Self else {
            return false
        }
        
        return (self == other)
    }
    #endif
    
}

public func ==(lhs: Coordinate, rhs: Coordinate) -> Bool {
    return (lhs.x == rhs.x && lhs.y == rhs.y)
}

//MARK: - Coordinate using Int type

public class CoordinateInt {
    
    /*! primarily designated to store longitude in degrees */
    public var x: Int
    /*! primarily designated to store latitude in degrees */
    public var y: Int
    
    public init(x: Int, y: Int){
        self.x = x
        self.y = y
    }

    // for CustomSerialization
    public required init(){
        self.x = 0
        self.y = 0
    }
    
    public required init(variableMap: [String : Any]) throws {
        
        guard let x = variableMap["x"] else { throw DictionaryInstantiationError.Representation(fieldName: "x", detail: "not found").error }
        guard let y = variableMap["y"] else { throw DictionaryInstantiationError.Representation(fieldName: "x", detail: "not found").error }
        
        self.x = x as! Int
        self.y = y as! Int
    }

}

//MARK: CustomStringConvertable
extension CoordinateInt: CustomStringConvertible {
    
    public var description: String {
        return "CoordinateInt: { long: \(self.x), lat: \(self.y) }"
    }
        
    #if COOPER
    public override func toString() -> String {
        return self.description
    }
    #endif
}

//MARK: CustomSerializable
extension CoordinateInt: CustomSerializable {

    public static var readingIgnoredVariableNames: Set<String> { return Set<String>() }
    public static var writingIgnoredVariableNames: Set<String> { return Set<String>() }
    
    public static var allowedTypeDifferentVariableNames: Set<String> { return Set<String>() }
    public static var variableNamesAlliases: [String: String] { return [String: String]() }
    
    public var manuallySerializedValues: [String: Any] { return [String: Any]() }
}

//MARK: Java's Equatable analogue
extension CoordinateInt: Equatable {
    
    #if COOPER
    public override func equals(_ o: Object!) -> Bool {
    
    guard let other = o as? Self else {
    return false
    }
    
    return (self == other)
    }
    #endif
    
}

public func ==(lhs: CoordinateInt, rhs: CoordinateInt) -> Bool {
    return (lhs.x == rhs.x && lhs.y == rhs.y)
}
