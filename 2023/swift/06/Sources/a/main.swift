import ArgumentParser
import Foundation

@main
struct Day06a: ParsableCommand {
  @Option(help: "Specify the input")
  public var input: String

  func numbers(_ fromString: String) -> [Int] {
    return fromString.components(separatedBy: " ").compactMap { Int($0) }
  }

  public func run() throws {
    guard let filecontent = try? String(contentsOfFile: input, encoding: .utf8)
    else {
        print("Failed to open file \(input)")
        return
    }

    let lines = filecontent.components(separatedBy: .newlines)
    let times = numbers(lines[0].components(separatedBy: ":")[1])
    let distances = numbers(lines[1].components(separatedBy: ":")[1])

    var result = 1
    for i in 0..<times.count {
      let distance = distances[i]
      let time = times[i]
      // (t - x) * x > d
      // tx - x^2 > d
      // -x^2 + tx - d > 0

      // delta = (t)^2 - 4d
      let delta =  time * time - 4 * distance
      let x1 = Int(floor((Double(time) + sqrt(Double(delta))) / 2 - 0.01))
      let x2 = Int(ceil((Double(time) - sqrt(Double(delta))) / 2 + 0.01))
      print (x1, x2, x1-x2)
      result *= x1 - x2 + 1
    }
    print(result)
  }
}