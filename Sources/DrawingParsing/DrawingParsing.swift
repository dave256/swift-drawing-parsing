//
//  DrawomgParsing.swift
//
//
//  Created by David M Reed on 02/22/24.
//

import CoreGraphics
import Drawing
import Parsing

// MARK: - Comment

/// for parsing text after a shape that is a comment for the shape
/// if no space/tab at start then no comment
/// an Enum so can't instantiate - just use the static parser() method
public enum Comment {
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

// MARK: CGPoint

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

// MARK: Transform

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
    static func arrayParserStartingWithNewline() -> some ParserPrinter<Substring, [Transform]> {
        ParsePrint(input: Substring.self) {

            OneOf {
                ParsePrint {
                    Many(1...) {
                        Transform.parser()
                    } separator: {
                        "\n"
                    } terminator: {
                        // terminate when find end of input or a newline after processing all transforms first
                        OneOf {
                            End()
                            // check for newline but don't consume/parse the newline
                            Peek { Whitespace(1, .vertical) }
                        }
                    }
                }

                ParsePrint {
                    Whitespace(1, .vertical)
                    Many(1...) {
                        Transform.parser()
                    } separator: {
                        "\n"
                    } terminator: {
                        // terminate when find end of input or a newline after processing all transforms first
                        OneOf {
                            End()
                            // check for newline but don't consume/parse the newline
                            Peek { Whitespace(1, .vertical) }
                        }
                    }
                }

                ParsePrint {
                    Whitespace(1, .vertical)
                    Not {
                        Transform.parser()
                    }
                }
                .map { [Transform]() }

                // if no newline at end then assume end of input with no transforms for last shape
                Not {
                    Whitespace(1, .vertical)
                }
                .map { [Transform]() }
            }
        }
    }

    /// zero or more transformations separated by a newline
    static func zeroOrMoreParser() -> some ParserPrinter<Substring, [Transform]> {
        ParsePrint(input: Substring.self) {
            Many(0...) {
                Transform.parser()
            } separator: {
                Whitespace(1, .vertical)
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

// MARK: DrawStyle

public extension DrawStyle {
    /// "path", "closed", or "filled" followed by one or more spaces/tabs followed by a color
    static func parser() -> some ParserPrinter<Substring, DrawStyle> {
        ParsePrint(input: Substring.self, .memberwise(DrawStyle.init)) {
            // allow leading spaces and tabs
            Whitespace(0..., .horizontal)
            Style.parser()
            Whitespace(1..., .horizontal)
            Color.parser()
            // allow trailing spaces and tabs
            Whitespace(0..., .horizontal)
        }
    }
}

// MARK: UnitSquare

public extension UnitSquare {

    /// "unit square" followed by a blank line followed by a DrawStyle (such as "filled red") followed by a blank line followed by Transforms (such as "r 45.0" or "s 2.5 3.5" or "t 1.5 2.5")
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
            Transform.arrayParserStartingWithNewline()
        }
    }
}

// MARK: UnitCircle

public extension UnitCircle {
    /// "unit circle" followed by a blank line followed by a DrawStyle (such as "filled red") followed by a blank line followed by Transforms (such as "r 45.0" or "s 2.5 3.5" or "t 1.5 2.5")
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
            Transform.arrayParserStartingWithNewline()
        }
    }
}
