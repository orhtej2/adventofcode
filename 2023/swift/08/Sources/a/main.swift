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
struct Day08: ParsableCommand {
  @Option(help: "Specify the input")
  public var input: String

  public func run() throws {
    guard let filecontent = try? String(contentsOfFile: input, encoding: .utf8)
    else {
        print("Failed to open file \(input)")
        return
    }

    let lines = filecontent.components(separatedBy: .newlines)
    let instructions = lines[0]

    var map = [String: [String]]()
    lines.dropFirst(2).forEach { line in
        let parts = line.components(separatedBy: "=")
        let key = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmed = parts[1][2..<parts[1].length-1]
        let value = trimmed.components(separatedBy: ", ")
        map[key] = value
    }

    var steps = 0
    var current = "AAA"
    var i = 0
    print(current)
    while current != "ZZZ" {
        let instruction = instructions[i]
        let step = map[current]!
        if instruction == "L" {
            current = step[0]
        } else {
            current = step[1]
        }
        print(current)
        steps += 1
        i += 1
        if i == instructions.length {
            i = 0
        }
    }

    print(steps)
  }
}
