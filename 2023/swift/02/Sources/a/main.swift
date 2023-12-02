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
    let available = [
        "red": 12,
        "green": 13,
        "blue": 14
    ]
    var result: Int = 0
    for line in filecontent.components(separatedBy: .newlines) {
        if (line.isEmpty) {
            break
        }
        print(line)
        let game = line.components(separatedBy: ":")
        let gameId = Int(game[0].split(separator: " ")[1])!
        var valid = true
        print(gameId)
        let draws = game[1].split(separator: ";")
        for draw in draws {
            if !valid {
                break
            }
            print(draw)
            let cubes = draw.split(separator: ",")
            for cube in cubes {
                if !valid {
                    break
                }
                let split = cube.split(separator: " ")
                let number = Int(split[0])!
                let color = String(split[1])
                print("\(number) \(color)")
                print("\(available[color]!) > \(number) == \(available[color]! > number)")
                if number > available[color]! {
                    valid = false
                }
            }
        }
        if valid {
            result += gameId
        }
    }
    print("Result: \(result)")
  }
}
