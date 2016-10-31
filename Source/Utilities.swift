//
//  Utilities.swift
//  LakestoneGeometry
//
//  Created by Volodymyr Andriychenko on 25/10/2016.
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

// these are needed for math functions, java would just use Math.<function_name>
#if os(OSX) || os(iOS) || os(watchOS) || os(tvOS)
    import Darwin.C
#elseif os(Linux)
    import Glibc
#endif


//MARK: - Global constants

public let roundoffEps = 1e-25

//MARK: - Spherical Mercator Projection

#if COOPER
private let _radianDegreeMultiplier = 180/Math.PI
#else
private let _radianDegreeMultiplier = 180/M_PI
#endif

public func sphericalMercatorLatitudeProjection(latitude: Double) -> Double {
    
    #if COOPER
    return Math.atan(Math.sinh(latitude/_radianDegreeMultiplier)) * _radianDegreeMultiplier
    #else
    return  atan(sinh(latitude/_radianDegreeMultiplier)) * _radianDegreeMultiplier
    #endif
}

public func localLatitudeFromSpericalMercatorProjection(latitude: Double) -> Double {
    
    var safeLatitude: Double
    
    // Spherical mercator project latitude gets bounded within [-85.0511287798066, 85.0511287798066]
    // if latitude passed is outside of these bounds -> use bound values instead
    safeLatitude = (latitude < -SphericalMercatorPoleLimit) ? -SphericalMercatorPoleLimit : latitude
    safeLatitude = (safeLatitude > SphericalMercatorPoleLimit) ? SphericalMercatorPoleLimit : safeLatitude
    
    #if COOPER
    return Math.log((1.0+Math.sin(safeLatitude/_radianDegreeMultiplier))/Math.cos(safeLatitude/_radianDegreeMultiplier)) * _radianDegreeMultiplier
    #else
    return log((1.0+sin(safeLatitude/_radianDegreeMultiplier))/cos(safeLatitude/_radianDegreeMultiplier)) * _radianDegreeMultiplier
    #endif
}

/** The most northest point achievable in spherical mercator coordinate system(85.0511287798066) */
public var SphericalMercatorPoleLimit: Double { return sphericalMercatorLatitudeProjection(latitude: 180.0) }
