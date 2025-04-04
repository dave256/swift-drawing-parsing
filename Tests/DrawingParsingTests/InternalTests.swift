//
//  InternalTests.swift
//  DrawingParsing
//
//  Created by David Reed on 3/30/25.
//


import InlineSnapshotTesting
import Testing

@testable import Drawing
@testable import DrawingParsing

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
struct InternalTests {

    @Test func oneSquareNoTransforms() throws {
        let input: Substring = """
unit square
filled red
"""
        let shapes = try DrawableShape.zeroOrMoreParser().parse(input)
        let expected = [DrawableShape.unitSquare(.init(drawStyle: .init(style: .filled, color: .red), transforms: []))]
        #expect(shapes == expected)
        let output = String(try DrawableShape.zeroOrMoreParser().print(shapes))
        assertInlineSnapshot(of: output, as: .lines) {
            """
            unit square
            filled red
            """
        }
        #expect(input == output)
    }

    @Test func oneSquareOneTransform() throws {
        let input: Substring = """
unit square
filled red
s 8.0 9.0
"""
        let shapes = try DrawableShape.zeroOrMoreParser().parse(input)
        let expected = [DrawableShape.unitSquare(.init(drawStyle: .init(style: .filled, color: .red), transforms: [.s(8, 9)]))]
        #expect(shapes == expected)
        let output = String(try DrawableShape.zeroOrMoreParser().print(shapes))
        assertInlineSnapshot(of: output, as: .lines) {
            """
            unit square
            filled red
            s 8.0 9.0
            """
        }
        #expect(input == output)
    }

    @Test func oneSquareMultipleTransforms() throws {
        let input: Substring = """
unit square
filled red
s 8.0 9.0
r 45.0
"""
        let shapes = try DrawableShape.zeroOrMoreParser().parse(input)
        let expected = [DrawableShape.unitSquare(.init(drawStyle: .init(style: .filled, color: .red), transforms: [.s(8, 9), .r(45)]))]
        #expect(shapes == expected)
        let output = String(try DrawableShape.zeroOrMoreParser().print(shapes))
        assertInlineSnapshot(of: output, as: .lines) {
            """
            unit square
            filled red
            s 8.0 9.0
            r 45.0
            """
        }
        #expect(input == output)
    }

    @Test func oneSquareWithName() throws {
        let input: Substring = """
unit square with a name
filled red
s 8.0 9.0
"""
        let shapes = try DrawableShape.zeroOrMoreParser().parse(input)
        let expected = [DrawableShape.unitSquare(.init(name: "with a name", drawStyle: .init(style: .filled, color: .red), transforms: [.s(8, 9)]))]
        #expect(shapes == expected)
    }

    @Test func oneSquareWithNamePrint() throws {
        let input: Substring = """
unit square with a name
filled red
s 8.0 9.0
"""
        let shapes = try DrawableShape.zeroOrMoreParser().parse(input)
        let expected = [DrawableShape.unitSquare(.init(name: "with a name", drawStyle: .init(style: .filled, color: .red), transforms: [.s(8, 9)]))]
        #expect(shapes == expected)
        let output = String(try DrawableShape.zeroOrMoreParser().print(shapes))
        assertInlineSnapshot(of: output, as: .lines) {
            """
            unit square with a name
            filled red
            s 8.0 9.0
            """
        }
        #expect(input == output)
    }

    @Test func oneCircle() throws {
        let input: Substring = """
unit circle
filled red
s 8.0 9.0
"""
        let shapes = try DrawableShape.zeroOrMoreParser().parse(input)
        let expected = [DrawableShape.unitCircle(.init(drawStyle: .init(style: .filled, color: .red), transforms: [.s(8, 9)]))]
        #expect(shapes == expected)
    }

    @Test func oneCircleWithName() throws {
        let input: Substring = """
unit circle circle 1
filled red
s 8.0 9.0
"""
        let shapes = try DrawableShape.zeroOrMoreParser().parse(input)
        let expected = [DrawableShape.unitCircle(.init(name: "circle 1", drawStyle: .init(style: .filled, color: .red), transforms: [.s(8, 9)]))]
        #expect(shapes == expected)
    }

    @Test func oneCircleWithNamePrint() throws {
        let input: Substring = """
unit circle circle 1
filled red
s 8.0 9.0
"""
        let shapes = try DrawableShape.zeroOrMoreParser().parse(input)
        let expected = [DrawableShape.unitCircle(.init(name: "circle 1", drawStyle: .init(style: .filled, color: .red), transforms: [.s(8, 9)]))]
        #expect(shapes == expected)
        let output = String(try DrawableShape.zeroOrMoreParser().print(shapes))
        assertInlineSnapshot(of: output, as: .lines) {
            """
            unit circle circle 1
            filled red
            s 8.0 9.0
            """
        }
        #expect(input == output)
    }

    @Test func multipleShapesNoTransforms() throws {

        let s = [
            DrawableShape.unitSquare(UnitSquare(drawStyle: .init(style: .filled, color: .red), transforms: [])),
            DrawableShape.unitCircle(UnitCircle(drawStyle: .init(style: .closed, color: .green), transforms: [])),
            DrawableShape.unitSquare(UnitSquare(drawStyle: .init(style: .closed, color: .green), transforms: [])),
        ]
        let output = String(try DrawableShape.zeroOrMoreParser().print(s))
        let input: Substring = """
unit square
filled red

unit circle
closed green

unit square
closed green
"""
        let shapes = try DrawableShape.zeroOrMoreParser().parse(input)
        #expect(shapes == s)
        assertInlineSnapshot(of: output, as: .lines) {
            """
            unit square
            filled red

            unit circle
            closed green

            unit square
            closed green
            """
        }
        #expect(input == output)
    }

    @Test func multipleShapes() throws {

        let s = [
            DrawableShape.unitSquare(UnitSquare(drawStyle: .init(style: .filled, color: .red), transforms: [])),
            DrawableShape.unitSquare(UnitSquare(drawStyle: .init(style: .closed, color: .green), transforms: [.s(8, 9), .r(45)])),
            DrawableShape.unitSquare(UnitSquare(drawStyle: .init(style: .closed, color: .green), transforms: [.r(45)])),
        ]
        let input: Substring = """
unit square
filled red

unit square
closed green
s 8.0 9.0
r 45.0

unit square
closed green
r 45.0
"""
        let shapes = try DrawableShape.zeroOrMoreParser().parse(input)
        #expect(shapes == s)
        let output = String(try DrawableShape.zeroOrMoreParser().print(shapes))
        assertInlineSnapshot(of: output, as: .lines) {
            """
            unit square
            filled red

            unit square
            closed green
            s 8.0 9.0
            r 45.0

            unit square
            closed green
            r 45.0
            """
        }
        #expect(output == input, "parsing passed, printing failed")
    }

    @Test func multipleShapesWithNamesNoTransforms() throws {

        let s = [
            DrawableShape.unitSquare(UnitSquare(name: "square 1", drawStyle: .init(style: .filled, color: .red), transforms: [])),
            DrawableShape.unitCircle(UnitCircle(name: "circle 1", drawStyle: .init(style: .closed, color: .green), transforms: [])),
            DrawableShape.unitSquare(UnitSquare(name: "square 2", drawStyle: .init(style: .closed, color: .green), transforms: [])),
        ]
        let output = String(try DrawableShape.zeroOrMoreParser().print(s))
        let input: Substring = """
unit square square 1
filled red

unit circle circle 1
closed green

unit square square 2
closed green
"""
        let shapes = try DrawableShape.zeroOrMoreParser().parse(input)
        #expect(shapes == s)
        assertInlineSnapshot(of: output, as: .lines) {
            """
            unit square square 1
            filled red

            unit circle circle 1
            closed green

            unit square square 2
            closed green
            """
        }
        #expect(input == output, "parsing passed, printing failed")
    }

    @Test func shapeGroupsParsingWithoutBlankLines() throws {
        let input: Substring = """
group abc
unit square name for the square
filled red
s 1.0 1.0
unit circle name
filled green
t 1.0 3.0

group
r 45.0
unit circle
filled red
s 1.5 2.0
t 2.0 3.0
unit circle
filled green
unit square name
filled red
s 3.0 5.0
t 6.0 7.0


"""
        let expectedOutput: Substring = """
group abc

unit square name for the square
filled red
s 1.0 1.0

unit circle name
filled green
t 1.0 3.0

group
r 45.0

unit circle
filled red
s 1.5 2.0
t 2.0 3.0

unit circle
filled green

unit square name
filled red
s 3.0 5.0
t 6.0 7.0
"""
        let g = try ShapeGroups.parser().parse(input)
        let expected: [DrawableShapeGroup] = [
            DrawableShapeGroup(
                name: "abc",
                transforms: [],
                shapes: [
                    .unitSquare(
                        UnitSquare(
                            name: "name for the square",
                            drawStyle: .init(style: .filled, color: .red),
                            transforms: [.s(1, 1)]
                        )
                    ),

                        .unitCircle(
                            UnitCircle(
                                name: "name",
                                drawStyle: .init(style: .filled, color: .green),
                                transforms: [.t(1, 3)]
                            )
                        )
                ]),

            DrawableShapeGroup(
                name: "",
                transforms: [.r(45)],
                shapes: [
                    .unitCircle(
                        UnitCircle(
                            name: "",
                            drawStyle: .init(style: .filled, color: .red),
                            transforms: [.s(1.5, 2), .t(2, 3)]
                        )
                    ),
                    .unitCircle(
                        UnitCircle(
                            name: "",
                            drawStyle: .init(style: .filled, color: .green),
                            transforms: []
                        )
                    ),

                        .unitSquare(
                            UnitSquare(
                                name: "name",
                                drawStyle: .init(style: .filled, color: .red),
                                transforms: [.s(3, 5), .t(6, 7)]
                            )
                        ),
                ]),
        ]
        #expect(expected == g)
        let output = String(try ShapeGroups.parser().print(g))
        assertInlineSnapshot(of: output, as: .lines) {
            """
            group abc

            unit square name for the square
            filled red
            s 1.0 1.0

            unit circle name
            filled green
            t 1.0 3.0

            group
            r 45.0

            unit circle
            filled red
            s 1.5 2.0
            t 2.0 3.0

            unit circle
            filled green

            unit square name
            filled red
            s 3.0 5.0
            t 6.0 7.0
            """
        }
        #expect(output == expectedOutput)
    }

    @Test func shapeGroupsWithPrint() throws {
        let input: Substring = """
group abc

unit square name for the square
filled red
s 1.0 1.0

unit circle name
filled green
t 1.0 3.0

group def
r 45.0

unit circle
filled red
s 1.0 1.0
t 2.0 3.0

unit circle
filled green

unit square name
filled red
s 3.0 5.0
t 6.0 7.0

unit circle
filled black
"""
        let g = try ShapeGroups.parser().parse(input)
        let output = String(try ShapeGroups.parser().print(g))
        assertInlineSnapshot(of: output, as: .lines) {
            """
            group abc

            unit square name for the square
            filled red
            s 1.0 1.0

            unit circle name
            filled green
            t 1.0 3.0

            group def
            r 45.0

            unit circle
            filled red
            s 1.0 1.0
            t 2.0 3.0

            unit circle
            filled green

            unit square name
            filled red
            s 3.0 5.0
            t 6.0 7.0

            unit circle
            filled black
            """
        }
        #expect(output == input)
    }

    @Test func minimalShapeGroup() throws {
        let input: Substring = """
group abc
r 45.0
unit circle
filled red
"""
        let g = try ShapeGroups.parser().parse(input)
        let expected: [DrawableShapeGroup] = [
            DrawableShapeGroup(
                name: "abc",
                transforms: [.r(45)],
                shapes: [
                    .unitCircle(UnitCircle(name: "", drawStyle: .init(style: .filled, color: .red), transforms: []))
                ]
            )
        ]
        #expect(expected == g)
        let output = String(try ShapeGroups.parser().print(g))
        assertInlineSnapshot(of: output, as: .lines) {
            """
            group abc
            r 45.0

            unit circle
            filled red
            """
        }
    }
}
