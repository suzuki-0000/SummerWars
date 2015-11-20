//
//  ColorDefinition.swift
//  RandomColorSwift
//
//  Copyright (c) 2015 Wei Wang (http://onevcat.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

typealias Range = (min: Int, max: Int)

struct ColorDefinition {
    let hueRange: Range?
    let lowerBounds: [Range]
    
    lazy var saturationRange: Range = {
        let sMin = self.lowerBounds[0].0
        let sMax = self.lowerBounds[self.lowerBounds.count - 1].0
        return (sMin, sMax)
    }()
    
    lazy var brightnessRange: Range = {
        let bMin = self.lowerBounds[self.lowerBounds.count - 1].1
        let bMax = self.lowerBounds[0].1
        return (bMin, bMax)
    }()
    
    init(hueRange: Range?, lowerBounds: [Range]) {
        self.hueRange = hueRange
        self.lowerBounds = lowerBounds
    }
}