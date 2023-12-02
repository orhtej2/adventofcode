import ArgumentParser
import Foundation

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
    let isNumber = { (c: Character) -> Bool in return c.isNumber }
    var result: Int = 0
    for line in filecontent.components(separatedBy: .newlines) {
        print(line)
        if let first = line.first(where: isNumber)?.wholeNumberValue {
            if let last = line.last(where: isNumber)?.wholeNumberValue {
                print("\(first) \(last)")
                result += first * 10 + last
            } else {
                print("Failed to find last number")
                continue
            }
        } else {
            print("Failed to find first number")
            continue
        }
    }
    print("Result: \(result)")
  }
}