import ArgumentParser
import Foundation

struct Card {
  var count = 1
  var score = 0
}

@main
struct Day05b: ParsableCommand {
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
    var cards = [Int: Card]()
    for line in filecontent.components(separatedBy: .newlines) {
        let split = line.components(separatedBy: [":", "|"])
        let card = Int(split[0].substring(from: 4).trimmingCharacters(in: [" "]))!
        let winning = Set<Int>(numbers(fromString: split[1]))
        let chosen = Set<Int>(numbers(fromString: split[2]))
        let winningCount = winning.intersection(chosen).count
        cards[card] = Card(count: 1, score: winningCount)
    }

    var result = 0
    for card in cards.keys.sorted() {
      let c = cards[card]!
      result += c.count
      if c.score > 0 {
        for i in 1...c.score {
          cards[card + i]!.count += c.count
        }
      }
    }
    print(result)
  }
}