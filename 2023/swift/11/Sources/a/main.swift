import ArgumentParser
import Foundation

@main
struct Day11: ParsableCommand {
  @Option(help: "Specify the input")
  public var input: String

  public func run() throws {
    guard let filecontent = try? String(contentsOfFile: input, encoding: .utf8)
    else {
        print("Failed to open file \(input)")
        return
    }

    let lines = filecontent.components(separatedBy: .newlines)
    var stars = [(Int, Int)]()
    for (y, line) in lines.enumerated() {
      for (x, element) in line.enumerated() {
        if element == "#" {
          stars.append((x, y))
        }
      }
    }
    var horizontal = Set<Int>()
    Set<Int>(0..<lines.count).symmetricDifference(Set<Int>(stars.map { $0.1 })).forEach { horizontal.insert($0) }

    var vertical = Set<Int>()
    Set<Int>(0..<lines[0].count)
      .symmetricDifference(Set<Int>(stars.map { $0.0 })).forEach { vertical.insert($0) }

    var result = 0
    for i in 0..<stars.count - 1 {
      for j in i+1..<stars.count {
        var result2 = 0
        let star1 = stars[i]
        let star2 = stars[j]
        for x in min(star1.0, star2.0)..<max(star1.0, star2.0) {
          result2 += 1
          if vertical.contains(x) {
            result2 += 1
          }
        }

        for y in min(star1.1, star2.1)..<max(star1.1, star2.1) {
          result2 += 1
          if horizontal.contains(y) {
            result2 += 1
          }
        }

        result += result2
        print("\(i) \(j) \(result2)")
      }
    }

    print(result)
  }
}
