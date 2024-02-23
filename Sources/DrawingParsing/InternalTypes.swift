//
//  InternalTypes.swift
//  
//
//  Created by David Reed on 2/22/24.
//

import Drawing
import Parsing
import SwiftUI

internal enum DrawableShape: Equatable {
    case unitSquare(UnitSquare)
    case unitCircle(UnitCircle)
}

extension DrawableShape: Drawable {
    func draw(context: GraphicsContext) {
        switch self {

        case .unitSquare(let ds):
            ds.draw(context: context)
        case .unitCircle(let ds):
            ds.draw(context: context)
        }
    }
}

extension DrawableShape {
    static func unitSquareParser() -> some ParserPrinter<Substring, DrawableShape> {
        ParsePrint(input: Substring.self, UnitSquareConversion()) {
            UnitSquare.parser()
        }
    }

    static func unitCircleParser() -> some ParserPrinter<Substring, DrawableShape> {
        ParsePrint(input: Substring.self, UnitCircleConversion()) {
            UnitCircle.parser()
        }
    }

    static func parser() -> some ParserPrinter<Substring, DrawableShape> {
        OneOf {
            unitSquareParser()
            unitCircleParser()
        }
    }

    /// zero or more ParseShapes with two newline characters between them
    static func zeroOrMoreParser() -> some ParserPrinter<Substring, [DrawableShape]> {
        ParsePrint(input: Substring.self) {
            Many(0...) {
                DrawableShape.parser()
            } separator: {
                Whitespace(1..., .vertical).printing("\n".utf8)
            }
        }
    }

    struct UnitSquareConversion: Conversion {
        public func apply(_ s: UnitSquare) -> DrawableShape {
            // make a UnitSquare
            DrawableShape.unitSquare(s)
        }

        public func unapply(_ shape: DrawableShape) throws -> UnitSquare {
            struct ParseError: Error {}
            switch shape {
                // handle the UnitSquare case
            case let .unitSquare(s):
                return s
            default:
                // throw an error for all other types for correct parsing/printing
                throw ParseError()
            }
        }
    }

    /// Conversion for parsing
    struct UnitCircleConversion: Conversion {
        public func apply(_ c: UnitCircle) -> DrawableShape {
            // make a UnitCircle
            DrawableShape.unitCircle(c)
        }

        public func unapply(_ shape: DrawableShape) throws -> UnitCircle {
            struct ParseError: Error {}
            switch shape {
                // handle the Circle case
            case let .unitCircle(s):
                return s
            default:
                // throw an error for all other types for correct parsing/printing
                throw ParseError()
            }
        }
    }
}

internal struct DrawableShapeGroup: Drawable, Transformable, Equatable {

    /// init
    /// - Parameters:
    ///   - name: name for the group
    ///   - transforms: transforms to apply to each shape in the group
    ///   - shapes: shapes that are part of the group
    init(name: String, transforms: [Transform] = [], shapes: [DrawableShape]) {
        self.name = name
        self.transforms = transforms
        self.shapes = shapes
    }

    /// a name for the group
    let name: String

    /// transforms to be applied to all the shapes in the group
    var transforms: [Transform] = []

    /// shapes to be drawn
    private(set) var shapes: [DrawableShape]

    /// combined transform from transforms applied in the order they are in the array
    var transform: CGAffineTransform { transforms.combined }

    /// draw all the shapes in the group first applying the shape's indvidiual transforms, followed by the group's transforms
    /// - Parameter context: context to draw with
    func draw(context: GraphicsContext) {
        // add the group's transform and then apply the context's transforms
        var context = context
        context.transform = transform.concatenating(context.transform)
        // draw each of the shapes
        for shape in shapes {
            shape.draw(context: context)
        }
    }
}

extension DrawableShapeGroup {
    static func parser() -> some ParserPrinter<Substring, DrawableShapeGroup> {
        ParsePrint(input: Substring.self, .memberwise(DrawableShapeGroup.init)) {
            Whitespace(0..., .vertical)
            "group"
            Comment.parser()
            Transform.arrayParserStartingWithNewline()
            Whitespace(0..., .vertical).printing("\n".utf8)
            DrawableShape.zeroOrMoreParser()
        }
    }

    static func zeroOrMoreParser() -> some ParserPrinter<Substring, [DrawableShapeGroup]> {
        ParsePrint(input: Substring.self) {
            OneOf {
                ParsePrint {
                    // first try to handle any white space before it and consume it
                    //Whitespace(0...)
                    // next look for one more more transforms separated by a newline
                    Many(1...) {
                        DrawableShapeGroup.parser()
                    } separator: {
                        Whitespace(1..., .vertical).printing("\n\n".utf8)
                    }
//                    Whitespace()
                }
                // if no transforms, this will leave the white space since we only consume it if there is at least one transform
                // this is necessary so we don't need two blank lines when there are no transforms
//                Whitespace(0..., .vertical).printing("".utf8).map { [DrawableShapeGroup]() }
            }
        }
    }
}
