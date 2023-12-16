import ArgumentParser
import Foundation

@main
struct Day09b: ParsableCommand {
  @Option(help: "Specify the input")
  public var input: String

  func numbers(_ fromString: String) -> [Int] {
    return fromString.components(separatedBy: " ").compactMap { Int($0) }
  }

  func diff(_ sequence: [Int]) -> [[Int]] {
    var result = [[Int]]()
    result.append(sequence)
    var j = 0
    
    while !result[j].allSatisfy({ $0 == 0 }) {
        j += 1
        result.append([])
        for i in 1..<result[j-1].count {
            result[j].append(result[j-1][i] - result[j-1][i-1])
        }
    }
    return result
  }

    func next(_ sequences: [[Int]]) -> Int {
      var d = 0
      for sequence in sequences.reversed() {
        d = sequence.first! - d
      }
      return d
    }


  public func run() throws {
    guard let filecontent = try? String(contentsOfFile: input, encoding: .utf8)
    else {
        print("Failed to open file \(input)")
        return
    }

    let lines = filecontent.components(separatedBy: .newlines)
    let sequences = lines.compactMap { numbers($0) }
    var result = 0
    for sequence in sequences {
        let diffs = diff(sequence)
        let n = next(diffs)
        print(n)
        result += n
    }
    print("Result is \(result)")
  }
}
