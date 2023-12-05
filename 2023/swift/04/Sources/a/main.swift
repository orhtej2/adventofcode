import ArgumentParser
import Foundation

@main
struct Day04a: ParsableCommand {
  @Option(help: "Specify the input")
  public var input: String

  func numbers(fromString: String) -> [Int] {
    return fromString.components(separatedBy: " ").compactMap { Int($0) }
  }
  public func run() throws {
    guard let filecontent = try? String(contentsOfFile: input, encoding: .utf8)
    else {
        print("Failed to open file \(input)")
        return
    }
    var result = 0
    for line in filecontent.components(separatedBy: .newlines) {
        let split = line.components(separatedBy: [":", "|"])
        //let card = Int(split[0].components(separatedBy: " ")[1])!
        let winning = Set<Int>(numbers(fromString: split[1]))
        let chosen = Set<Int>(numbers(fromString: split[2]))
        let winningCount = winning.intersection(chosen).count
        if winningCount > 0 {
            result += 1<<(winningCount - 1)
        }
    }
    print(result)
  }
}