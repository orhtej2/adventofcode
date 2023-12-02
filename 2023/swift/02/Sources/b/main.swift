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
    var result: Int = 0
    for line in filecontent.components(separatedBy: .newlines) {
        if (line.isEmpty) {
            break
        }
        print(line)
        let game = line.components(separatedBy: ":")
        let gameId = Int(game[0].split(separator: " ")[1])!
        var power = [
            "red": 0,
            "green": 0,
            "blue": 0
        ]
        print(gameId)
        let draws = game[1].split(separator: ";")
        for draw in draws {
            print(draw)
            let cubes = draw.split(separator: ",")
            for cube in cubes {
                let split = cube.split(separator: " ")
                let number = Int(split[0])!
                let color = String(split[1])
                if number > power[color]! {
                    power[color] = number
                }
            }
        }
        result += power["red"]! * power["green"]! * power["blue"]!
    }
    print("Result: \(result)")
  }
}
