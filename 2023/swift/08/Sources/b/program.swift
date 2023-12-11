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

    // https://gist.github.com/aniltv06/6f3e9c6208e27a89259919eeb3c3d703
    func gcd(_ x: UInt128, _ y: UInt128) -> UInt128 {
        var a = UInt128(0)
        var b = max(x, y)
        var r = min(x, y)
        
        while r != 0 {
            a = b
            b = r
            r = a % b
        }
        return b
    }

    /*
    Returns the least common multiple of two numbers.
    */
    func lcm(_ x: UInt128, _ y: UInt128) -> UInt128 {
        return x / gcd(x, y) * y
    }

    func lcm(_ numbers: [UInt128]) -> UInt128 {
        return numbers.reduce(1) { lcm($0, $1) }
    }

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
    var current = map.keys.filter { $0[2] == "A" }
    var i = 0
    print(current)
    var results = [UInt128]()
    while !current.allSatisfy({ $0[2] == "Z" }) {
        let instruction = instructions[i]
        for i in 0..<current.count {
            let step = map[current[i]]!
            if instruction == "L" {
                current[i] = step[0]
            } else {
                current[i] = step[1]
            }
        }
        steps += 1
        
        let found = current.filter { $0[2] == "Z" }
        for f in found {
            print(f)
            results.append(UInt128(exactly: steps)!)
        }
        current = current.filter { $0[2] != "Z" }

        i += 1
        if i == instructions.length {
            i = 0
        }
    }

    print(results)
    print(lcm(results))
  }
}
