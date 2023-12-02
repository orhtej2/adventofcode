import ArgumentParser
import Foundation

@main
struct Day01a: ParsableCommand {
  @Option(help: "Specify the input")
  public var input: String

    func replace(_ s: String) -> String {
        let replacements = [
            "one": "1",
            "two": "2",
            "three": "3",
            "four": "4",
            "five": "5",
            "six": "6",
            "seven": "7",
            "eight": "8",
            "nine": "9",
        ]
        var result: String = ""
        for idx in s.indices {
            if s[idx].isNumber {
                result.append(s[idx])
            } else {
                for replacement in replacements {
                    if s[idx...].starts(with: replacement.key) {
                        result.append(replacement.value)
                        break
                    }
                }
            }
        }
        return result
    }

  public func run() throws {
    guard let filecontent = try? String(contentsOfFile: input, encoding: .utf8)
    else {
        print("Failed to open file \(input)")
        return
    }
    let isNumber = { (c: Character) -> Bool in return c.isNumber }

    var result: Int = 0
    for line in filecontent.components(separatedBy: .newlines) {
        let input: String = replace(line)
        print(line)
        print(input)
        if let first = input.first(where: isNumber)?.wholeNumberValue {
            if let last = input.last(where: isNumber)?.wholeNumberValue {
                print("\(first)\(last)")
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