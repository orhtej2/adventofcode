import ArgumentParser
import Foundation

@main
struct Day06b: ParsableCommand {
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
    let time = Int(lines[0].components(separatedBy: ":")[1].replacingOccurrences(of: " ", with: ""))!
    let distance = Int(lines[1].components(separatedBy: ":")[1].replacingOccurrences(of: " ", with: ""))!

    let delta =  time * time - 4 * distance
    let x1 = Int(floor((Double(time) + sqrt(Double(delta))) / 2 - 0.01))
    let x2 = Int(ceil((Double(time) - sqrt(Double(delta))) / 2 + 0.01))
    print (x1, x2, x1-x2)
    print(x1 - x2 + 1)
  }
}