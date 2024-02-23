//
//  DrawomgParsing.swift
//
//
//  Created by David M Reed on 02/22/24.
//

import CoreGraphics
import Drawing
import Parsing

public extension CGPoint {

    /// two numbers (can be int or double) separated by one or more spaces
    static func parser() -> some ParserPrinter<Substring, CGPoint> {
        ParsePrint(input: Substring.self, .memberwise(CGPoint.init(x:y:))) {
            // allow leading spaces/tabs
            Whitespace(0..., .horizontal)
            // x
            Double.parser()
            // at least one space between numbers
            Whitespace(1..., .horizontal)
            // y
            Double.parser()
            // allow trailing spaces/tabs
            Whitespace(0..., .horizontal)
        }
    }

    /// array of CGPoint - each point on its own line
    static func oneOrMoreParser() -> some ParserPrinter<Substring, [CGPoint]> {
        ParsePrint(input: Substring.self) {
            Many(1...) {
                CGPoint.parser()
            } separator: {
                // each point must be on its own line
                "\n"
            }
        }
    }
}

// MARK: -

public extension DrawStyle {
    /// "path", "closed", or "filled" followed by one or more spaces/tabs followed by a color
    static func parser() -> some ParserPrinter<Substring, DrawStyle> {
        ParsePrint(input: Substring.self, .memberwise(DrawStyle.init)) {
            // allow leading spaces and tabs
            Whitespace(0..., .horizontal)
            // filled, closed or path
            Style.parser()
            Whitespace(1..., .horizontal)
            Color.parser()
            // allow trailing spaces and tabs
            Whitespace(0..., .horizontal)
        }
    }
}

// MARK: -

public extension Transform {

    // a transform is one of the rotate, scale, or translate transformation
    static func parser() -> some ParserPrinter<Substring, Transform> {
        ParsePrint(input: Substring.self) {
            // allow leading spaces/tabs
            Whitespace(0..., .horizontal)
            OneOf {
                rotateParsePrint()
                scaleParsePrint()
                translateParsePrint()
            }
            // allow trailing spaces/tabs
            Whitespace(0..., .horizontal)
        }
    }
    
    /// use this one for paring transforms after shapes
    static func zeroOrMoreParser() -> some ParserPrinter<Substring, [Transform]> {
        ParsePrint(input: Substring.self) {
            OneOf {
                // if we have one or more transforms, parse them
                ParsePrint {
                    // confirming there is a transform but doesn't remove it
                    Peek { Transform.parser() }
                    // now parse all the transforms separated by a \n
                    Many(1...) {
                        Transform.parser()
                    } separator: {
                        "\n"
                    }
                }

                // no transforms just just skip and return empty array
                Not {
                    Transform.parser()
                }
                .map { [Transform]() }
            }
        }
    }

    /// r followed by one or more spaces/tabs, followed by the angle in degrees
    static func rotateParsePrint() -> some ParserPrinter<Substring, Transform> {
        ParsePrint(input: Substring.self, RotateConversion()) {
            "r"
            Whitespace(1..., .horizontal)
            Double.parser()
        }
    }

    /// s followed by one ore more spaces followed by a number for the x scale, followed by one ore more spaces followed by the number for the y scale
    static func scaleParsePrint() -> some ParserPrinter<Substring, Transform> {
        ParsePrint(input: Substring.self, ScaleConversion()) {
            "s"
            Whitespace(1..., .horizontal)
            Double.parser()
            Whitespace(1..., .horizontal)
            Double.parser()
        }
    }

    /// t followed by one ore more spaces followed by a number for the x translation, followed by one ore more spaces followed by the number for the y translation
    static func translateParsePrint() -> some ParserPrinter<Substring, Transform> {
        ParsePrint(input: Substring.self, TranslateConversion()) {
            "t"
            Whitespace(1..., .horizontal)
            Double.parser()
            Whitespace(1..., .horizontal)
            Double.parser()
        }
    }

    /// Conversion necessary for parsing
    struct RotateConversion: Conversion {
        public func apply(_ angle: Double) -> Transform {
            // make a Transform from the angle
            Transform.r(angle)
        }

        public func unapply(_ transform: Transform) throws -> Double {
            struct ParseError: Error {}
            switch transform {
                // handle the rotation case
            case let .r(angle):
                return angle
            default:
                // throw an error for all other types for correct parsing/printing
                throw ParseError()
            }
        }
    }

    /// Conversion necessary for parsing
    struct ScaleConversion: Conversion {
        public func apply(_ scales: (Double, Double)) -> Transform {
            // make a Transform with the scale values
            Transform.s(scales.0, scales.1)
        }

        public func unapply(_ transform: Transform) throws -> (Double, Double) {
            struct ParseError: Error {}
            switch transform {
                // handle the scale case
            case let .s(sx, sy):
                return (sx, sy)
            default:
                // throw an error for all other types for correct parsing/printing
                throw ParseError()
            }
        }
    }

    /// Conversion necessary for parsing
    struct TranslateConversion: Conversion {
        public func apply(_ translates: (Double, Double)) -> Transform {
            // make a Transform with the translation values
            Transform.t(translates.0, translates.1)
        }

        public func unapply(_ transform: Transform) throws -> (Double, Double) {
            struct ParseError: Error {}
            switch transform {
                // handle the translation case case
            case let .t(tx, ty):
                return (tx, ty)
            default:
                // throw an error for all other types for correct parsing/printing
                throw ParseError()
            }
        }
    }
}
// MARK: -

public enum ShapeTransforms {
    /// for parsing transforms at end of a shape or group
    public static func parser() -> some ParserPrinter<Substring, [Transform]> {
        OneOf {
            // find \n followed by transform, parse the transforms
            // this leaves the \n there since it could be the
            // separator for the next shape
            ParsePrint {
                Whitespace(1, .vertical)
                Peek { Transform.parser() }
                Transform.zeroOrMoreParser()
            }

            // find \n but then not a transform so no transforms
            // this leaves the \n there since it could be the
            // separator for the next shape
            ParsePrint {
                Peek {
                    Whitespace(1, .vertical)
                    Not { Transform.parser() }
                }
            }.map { [Transform]() }

            // end of input so no transforms
            End().map { [Transform]() }
        }
    }
}


// MARK: -

/// for parsing a comment at end of line that starts with spaces/tab s ((leading spaces/tabs are not part of comment)
/// if no space/tab at start then just returns ""
/// an Enum so can't instantiate - just use the static parser() method
public enum Comment {

    /// for parsing text to end of line
    public static func parser() -> some ParserPrinter<Substring, String> {
        // rest of line can have a name/comment
        OneOf {
            // either a space followed by comment
            ParsePrint {
                Whitespace(1..., .horizontal).printing(" ".utf8)
                PrefixUpTo("\n").map(.string)
            }
            // or if no horizontal white space then assume no comment
            Not {
                Whitespace(1..., .horizontal)
            }.map { "" }
        }
    }
}

// MARK: -

public extension UnitSquare {

    /// "unit square" followed by optional name/comment,  newline, a DrawStyle (such as "filled red") new line followed by Transforms (such as "r 45.0" or "s 2.5 3.5" or "t 1.5 2.5")
    static func parser() -> some ParserPrinter<Substring, UnitSquare> {
        ParsePrint(input: Substring.self, .memberwise(UnitSquare.init(name:drawStyle:transforms:))) {
            // allow leading spaces and tabs
            Whitespace(0..., .horizontal)
            "unit square"
            // optional comment/name for the shape which parses the vertical whitespace at end of line
            Comment.parser()
            Whitespace(1, .vertical)
            // style and color
            DrawStyle.parser()
            // this handles newline and optional transforms for shape
            ShapeTransforms.parser()
        }
    }
}

// MARK: -

public extension UnitCircle {
    /// "unit circle" followed by optional name/comment,  newline, a DrawStyle (such as "filled red") new line followed by Transforms (such as "r 45.0" or "s 2.5 3.5" or "t 1.5 2.5")
    static func parser() -> some ParserPrinter<Substring, UnitCircle> {
        ParsePrint(input: Substring.self, .memberwise(UnitCircle.init)) {
            // allow leading spaces and tabs
            Whitespace(0..., .horizontal)
            "unit circle"
            // optional comment/name for the shape which parses the vertical whitespace at end of line
            Comment.parser()
            Whitespace(1, .vertical)
            // style and color
            DrawStyle.parser()
            // this handles newline and optional transforms for shape
            ShapeTransforms.parser()
        }
    }
}
