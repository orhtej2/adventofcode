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



@main
struct Day01a: ParsableCommand {
  @Option(help: "Specify the input")
  public var input: String

  public func run() throws {
    guard let filecontent = try? String(contentsOfFile: input, encoding: .utf8)
    else {
        print("Failed to open file \(input)")
        return
    }
    var schematic = [String]()
    for line in filecontent.components(separatedBy: .newlines) {
        if (line.isEmpty) {
            break
        }
        schematic.append("." + line + ".")
    }
    let filler: String = "".padding(toLength: schematic[0].lengthOfBytes(using: .utf8), withPad: ".", startingAt: 0)
    schematic.insert(filler, at: 0)
    schematic.append(filler)
    let touchesPart = { (schematic: [String], x: Int, y: Int) -> Bool in
        for i in -1...1 {
            for j in -1...1 {
                if i == 0 && j == 0 {
                    continue
                }
                if schematic[y + i][x + j] != "." && !schematic[y + i][x + j].first!.isNumber {
                    return true
                }
            }
        }
        return false;// schematic[y].row.index(row.startIndex, offsetBy: x) != "."
    }
    let width = schematic[0].lengthOfBytes(using: .utf8)
    var result: Int = 0
    for i in 1...schematic.count-1 {
        var j = 1
        var start = -1
        while j < width {
            if schematic[i][j].first!.isNumber {
                if start == -1 {
                    start = j
                }
            } else {
                start = -1
            }
            if start != -1 && touchesPart(schematic, j, i) {
                while schematic[i][j].first!.isNumber {
                    j += 1
                }
                let numberString = schematic[i][start..<j]
                // print(numberString)
                let value = Int(numberString)!
                print(value)
                result += value
                start = -1
            }
            j += 1
        }
    }
    print("Result: \(result)")
  }
}
