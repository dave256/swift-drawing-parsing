import XCTest
@testable import Drawing
@testable import DrawingParsing

extension StringProtocol {
    var trimTrailingWhiteSpace: String {
        String(self.reversed().drop(while: { $0.isWhitespace } ).reversed())
    }

    func spacesAtEndOfLinesRemoved() -> String {
        self.components(separatedBy: "\n").map { $0.trimTrailingWhiteSpace }.joined(separator: "\n")
        //return lines.joined(separator: "\n")
    }
}

final class InternalTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testOneSquareNoTransforms() throws {
        let input: Substring = """
unit square
filled red
"""
        let shapes = try DrawableShape.zeroOrMoreParser().parse(input)
        let expected = [DrawableShape.unitSquare(.init(drawStyle: .init(style: .filled, color: .red), transforms: []))]
        XCTAssertEqual(shapes, expected)
        let output: Substring = try DrawableShape.zeroOrMoreParser().print(shapes)
        XCTAssertEqual(input.spacesAtEndOfLinesRemoved(), output.spacesAtEndOfLinesRemoved())
    }

    func testOneSquare() throws {
        let input: Substring = """
unit square
filled red
s 8 9
"""
        let shapes = try DrawableShape.zeroOrMoreParser().parse(input)
        let expected = [DrawableShape.unitSquare(.init(drawStyle: .init(style: .filled, color: .red), transforms: [.s(8, 9)]))]
        XCTAssertEqual(shapes, expected)
    }

    func testOneSquarePrint() throws {
        let input: Substring = "unit square\nfilled red\ns 8.0 9.0"
        let shapes = try DrawableShape.zeroOrMoreParser().parse(input)
        let expected = [DrawableShape.unitSquare(.init(drawStyle: .init(style: .filled, color: .red), transforms: [.s(8, 9)]))]
        XCTAssertEqual(shapes, expected)
        let output = try DrawableShape.zeroOrMoreParser().print(shapes)
        XCTAssertEqual(input, output)
    }

    func testOneSquareWithName() throws {
        let input: Substring = "unit square with a name\nfilled red\ns 8.0 9.0"
        let shapes = try DrawableShape.zeroOrMoreParser().parse(input)
        let expected = [DrawableShape.unitSquare(.init(name: "with a name", drawStyle: .init(style: .filled, color: .red), transforms: [.s(8, 9)]))]
        XCTAssertEqual(shapes, expected)
    }

    func testOneSquareWithNamePrint() throws {
        let input: Substring = """
unit square with a name
filled red
s 8.0 9.0
"""
        let shapes = try DrawableShape.zeroOrMoreParser().parse(input)
        let expected = [DrawableShape.unitSquare(.init(name: "with a name", drawStyle: .init(style: .filled, color: .red), transforms: [.s(8, 9)]))]
        XCTAssertEqual(shapes, expected)
        let output = try DrawableShape.zeroOrMoreParser().print(shapes)
        XCTAssertEqual(input, output)
    }

    func testOneCircle() throws {
        let input: Substring = """
unit circle
filled red
s 8.0 9.0
"""
        let shapes = try DrawableShape.zeroOrMoreParser().parse(input)
        let expected = [DrawableShape.unitCircle(.init(drawStyle: .init(style: .filled, color: .red), transforms: [.s(8, 9)]))]
        XCTAssertEqual(shapes, expected)
    }

    func testOneCircleWithName() throws {
        let input: Substring = """
unit circle circle 1
filled red
s 8.0 9.0
"""
        let shapes = try DrawableShape.zeroOrMoreParser().parse(input)
        let expected = [DrawableShape.unitCircle(.init(name: "circle 1", drawStyle: .init(style: .filled, color: .red), transforms: [.s(8, 9)]))]
        XCTAssertEqual(shapes, expected)
    }

    func testMultipleShapes() throws {

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
        XCTAssertEqual(shapes, s)

        let output = try DrawableShape.zeroOrMoreParser().print(shapes)
//        print("output")
//        print(output)
//        print("end")
//
//        print("input")
//        print(input)
//        print("end")
        print(output)
        let inputNoBlankLines = input.replacing("\n\n", with: "\n")
        let outputNoBlankLines = output.replacing("\n\n", with: "\n")
        XCTAssertEqual(inputNoBlankLines.spacesAtEndOfLinesRemoved(), outputNoBlankLines.spacesAtEndOfLinesRemoved())
    }

    func testMultipleShapesNoTransforms() throws {

        let s = [
            DrawableShape.unitSquare(UnitSquare(drawStyle: .init(style: .filled, color: .red), transforms: [])),
            DrawableShape.unitCircle(UnitCircle(drawStyle: .init(style: .closed, color: .green), transforms: [])),
            DrawableShape.unitSquare(UnitSquare(drawStyle: .init(style: .closed, color: .green), transforms: [])),
        ]
        let output = try DrawableShape.zeroOrMoreParser().print(s)
//        print("output")
//        print(output)
//        print("end")
        let input: Substring = """
unit square
filled red

unit circle
closed green

unit square
closed green
"""
//        print("input")
//        print(input)
//        print("end")
        let shapes = try DrawableShape.zeroOrMoreParser().parse(input)
        XCTAssertEqual(shapes, s)
        XCTAssertEqual(input, output)
    }

    func testMultipleShapesWithNamesNoTransforms() throws {

        let s = [
            DrawableShape.unitSquare(UnitSquare(name: "square 1", drawStyle: .init(style: .filled, color: .red), transforms: [])),
            DrawableShape.unitCircle(UnitCircle(name: "circle 1", drawStyle: .init(style: .closed, color: .green), transforms: [])),
            DrawableShape.unitSquare(UnitSquare(name: "square 2", drawStyle: .init(style: .closed, color: .green), transforms: [])),
        ]
        let output = try DrawableShape.zeroOrMoreParser().print(s)
//        print("output")
//        print(output)
//        print("end")
        let input: Substring = """
unit square square 1
filled red

unit circle circle 1
closed green

unit square square 2
closed green
"""
        let shapes = try DrawableShape.zeroOrMoreParser().parse(input)
        XCTAssertEqual(shapes, s)
        XCTAssertEqual(input, output)
    }

    func testShapeGroup() throws {
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
"""
        let g = try DrawableShapeGroup.zeroOrMoreParser().parse(input)
        let output = try DrawableShapeGroup.zeroOrMoreParser().print(g)
        print(output)
        XCTAssertEqual(input, output)
    }
}
