import ArgumentParser
import Foundation

extension String {
    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

struct Point: Hashable {
    let x: Int
    let y: Int
}

@main
struct Day01a: ParsableCommand {
  @Option(help: "Specify the input")
  public var input: String

  func touchesStar(schematic: [String], x: Int, y: Int) -> Point? {
        for i in -1...1 {
            for j in -1...1 {
                if i == 0 && j == 0 {
                    continue
                }
                if schematic[y + i][x + j] == "*" {
                    return Point(x: x + j, y: y + i)
                }
            }
        }
        return nil
    }

   func getNumbersForLine(schematic: [String], y: Int) -> [Point: [Int]] {
        var result = [Point: [Int]]()
        var j = 1
        var start = -1
        while j < schematic[y].length-1 {
            if schematic[y][j].first!.isNumber {
                if start == -1 {
                    start = j
                }
            } else {
                start = -1
            }
            if start != -1, let point = touchesStar(schematic: schematic, x: j, y: y) {
                while schematic[y][j].first!.isNumber {
                    j += 1
                }
                let numberString = schematic[y][start..<j]
                let value = Int(numberString)!
                result[point] = result[point] ?? [Int]()
                result[point]!.append(value)
                start = -1
            }
            j += 1
        }
        return result
    }

  public func run() throws {
    guard let filecontent = try? String(contentsOfFile: input, encoding: .utf8)
    else {
        print("Failed to open file \(input)")
        return
    }
    var schematic = [String]()
    for line in filecontent.components(separatedBy: .newlines) {
        if line.isEmpty {
            break
        }
        schematic.append("." + line + ".")
    }
    let filler: String = "".padding(toLength: schematic[0].lengthOfBytes(using: .utf8), withPad: ".", startingAt: 0)
    schematic.insert(filler, at: 0)
    schematic.append(filler)

    var gears = [Point: [Int]]()
    for i in 1...schematic.count-1 {
        gears.merge(getNumbersForLine(schematic: schematic, y: i)) { (current, new) in
            return current + new
        }
    }

    var result: Int = 0
    for (key, value) in gears {
        if value.count == 2 {
            print("Found gear at \(key) with \(value)")
            result += value[0] * value[1]
        }
    }
    print("Result: \(result)")
  }
}
