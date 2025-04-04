import Testing

import Foundation
import InlineSnapshotTesting

@testable import Drawing
@testable import DrawingParsing

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
struct CGPointParsingTests {
    @Test func parsePoint() throws {
        let input: Substring = "2.75 3.5"
        let p = try CGPoint.parser().parse(input)
        #expect(p == CGPoint(x: 2.75, y: 3.5))
    }

    @Test func printPoint() throws {
        let p = CGPoint(x: 2, y: 3)
        let output = String(try CGPoint.parser().print(p))
        //#expect(output == "2.0 3.0")
        assertInlineSnapshot(of: output, as: .lines) {
            """
            2.0 3.0
            """
        }
    }

    @Test func parseArrayPoints() throws {
        let input: Substring = "2 3\n4 5"
        let pts = try CGPoint.oneOrMoreParser().parse(input)
        #expect(pts == [CGPoint(x: 2, y: 3), CGPoint(x: 4, y: 5)])
    }

    @Test func printArrayPoints() throws {
        let pts =  [CGPoint(x: 2, y: 3), CGPoint(x: 4, y: 5), CGPoint(x: 10.5, y: 11.5)]
        let output = String(try CGPoint.oneOrMoreParser().print(pts))
        assertInlineSnapshot(of: output, as: .lines) {
            """
            2.0 3.0
            4.0 5.0
            10.5 11.5
            """
        }
    }
}

@Suite struct TransformParsingTests {
    @Test func parseRotate() throws {
        let input: Substring = "r 45"
        let t = try Transform.parser().parse(input)
        #expect(t == Transform.r(45))
    }

    @Test func printRotate() throws {
        let t = Transform.r(45)
        let output = String(try Transform.parser().print(t))
        assertInlineSnapshot(of: output, as: .lines) {
            """
            r 45.0
            """
        }
    }

    @Test func parseScale() throws {
        let input: Substring = "s 2.5 3.5"
        let t = try Transform.parser().parse(input)
        #expect(t == Transform.s(2.5, 3.5))
    }

    @Test func printScale() throws {
        let t = Transform.s(3.5, 2.5)
        let output = String(try Transform.parser().print(t))
        assertInlineSnapshot(of: output, as: .lines) {
            """
            s 3.5 2.5
            """
        }
    }

    @Test func parseTranslate() throws {
        let input: Substring = "t 2.5 3.5"
        let t = try Transform.parser().parse(input)
        #expect(t == Transform.t(2.5, 3.5))
    }

    @Test func printTranslate() throws {
        let t = Transform.t(3.5, 2.5)
        let output = String(try Transform.parser().print(t))
        assertInlineSnapshot(of: output, as: .lines) {
            """
            t 3.5 2.5
            """
        }
    }

    @Test func parseZeroTransform() throws {
        let input: Substring = ""
        let tfms = try Transform.zeroOrMoreParser().parse(input)
        #expect(tfms == [])
    }

    @Test func printZeroTransform() throws {
        let tfms: [Transform] = []
        let output = String(try Transform.zeroOrMoreParser().print(tfms))
        #expect(output == "")
        assertInlineSnapshot(of: output, as: .lines) {
            """

            """
        }

    }

    @Test func parseThreeTransforms() throws {
        let input: Substring = """
        s 2.5 3.5
        r 45.5
        t 4.5 5.25
        """
        let tfms = try Transform.zeroOrMoreParser().parse(input)
        #expect(tfms == [.s(2.5, 3.5), .r(45.5), .t(4.5, 5.25)])
    }

    @Test func printThreeTransforms() throws {
        let tfms: [Transform] = [.s(2.5, 3.5), .r(45.5), .t(4.5, 5.25)]
        let output = String(try Transform.zeroOrMoreParser().print(tfms))
        assertInlineSnapshot(of: output, as: .lines) {
            """
            s 2.5 3.5
            r 45.5
            t 4.5 5.25
            """
        }
    }
}

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
struct DrawStyleParsingTests {

    @Test func parseDrawableStyle() throws {
        var input: Substring = "path red"
        var ds = try DrawStyle.parser().parse(input)
        #expect(ds == DrawStyle(style: .path, color: .red))

        input = "closed blue"
        ds = try DrawStyle.parser().parse(input)
        #expect(ds == DrawStyle(style: .closed, color: .blue))

        input = "filled green"
        ds = try DrawStyle.parser().parse(input)
        #expect(ds == DrawStyle(style: .filled, color: .green))
    }

    @Test func printDrawableStyle() throws {
        var ds = DrawStyle(style: .path, color: .red)
        var output = String(try DrawStyle.parser().print(ds))
        assertInlineSnapshot(of: output, as: .lines) {
            """
            path red
            """
        }

        ds = DrawStyle(style: .closed, color: .blue)
        output = String(try DrawStyle.parser().print(ds))
        assertInlineSnapshot(of: output, as: .lines) {
            """
            closed blue
            """
        }

        ds = DrawStyle(style: .filled, color: .green)
        output = String(try DrawStyle.parser().print(ds))
        assertInlineSnapshot(of: output, as: .lines) {
            """
            filled green
            """
        }
    }
}

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
struct UnitCircleParsingTests {

    @Test func parseNoTransforms() throws {
        let input: Substring = "unit circle\npath red"
        let c = try UnitCircle.parser().parse(input)
        #expect(c == UnitCircle(drawStyle: DrawStyle(style: .path, color: .red), transforms: []))
    }

    @Test func parseTransforms() throws {
        let input: Substring = "unit circle\nfilled blue\nr 45.0\ns 2.0 3.0"
        let c = try UnitCircle.parser().parse(input)
        #expect(c == UnitCircle(drawStyle: DrawStyle(style: .filled, color: .blue), transforms: [.r(45), .s(2, 3)]))
    }

    @Test func printNoTransforms() throws {
        let c = UnitCircle(drawStyle: DrawStyle(style: .path, color: .red), transforms: [])
        let output = String(try UnitCircle.parser().print(c))
        assertInlineSnapshot(of: output, as: .lines) {
            """
            unit circle
            path red
            """
        }
    }

    @Test func printTransforms() throws {
        let c = UnitCircle(drawStyle: DrawStyle(style: .filled, color: .blue), transforms: [.r(45), .s(2, 3)])
        let output = String(try UnitCircle.parser().print(c))
        assertInlineSnapshot(of: output, as: .lines) {
            """
            unit circle
            filled blue
            r 45.0
            s 2.0 3.0
            """
        }
    }
}

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
struct UnitSquareParsingTests {

    @Test func parseNoTransforms() throws {
        let input: Substring = "unit square\npath red"
        let c = try UnitSquare.parser().parse(input)
        #expect(c == UnitSquare(drawStyle: DrawStyle(style: .path, color: .red), transforms: []))
    }

    @Test func parseTransforms() throws {
        let input: Substring = "unit square\nfilled blue\nr 45.0\ns 2.0 3.0"
        let c = try UnitSquare.parser().parse(input)
        #expect(c == UnitSquare(drawStyle: DrawStyle(style: .filled, color: .blue), transforms: [.r(45), .s(2, 3)]))
    }

    @Test func printNoTransforms() throws {
        let c = UnitSquare(drawStyle: DrawStyle(style: .path, color: .red), transforms: [])
        let output = String(try UnitSquare.parser().print(c))
        assertInlineSnapshot(of: output, as: .lines) {
            """
            unit square
            path red
            """
        }
    }

    @Test func printTransforms() throws {
        let c = UnitSquare(drawStyle: DrawStyle(style: .filled, color: .blue), transforms: [.r(45), .s(2, 3)])
        let output = String(try UnitSquare.parser().print(c))
        assertInlineSnapshot(of: output, as: .lines) {
            """
            unit square
            filled blue
            r 45.0
            s 2.0 3.0
            """
        }
    }
}

