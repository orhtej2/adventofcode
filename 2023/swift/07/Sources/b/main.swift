import ArgumentParser
import Foundation

extension String {
    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

enum HandType: Int {
    case fiveOfKind = 6
    case fourOfKind = 5
    case fullHouse = 4
    case threeOfKind = 3
    case twoPairs = 2
    case onePair = 1
    case highCard = 0
}

struct Hand {
    let cards: String
    let type: HandType
    let typeWithoutJoker: HandType
}

let values = ["J", "2", "3", "4", "5", "6", "7", "8", "9", "T", "Q", "K", "A"]

func compareHands (lhs: String, rhs: String) -> Bool {
    for i in 0..<lhs.count {
        if lhs[i] == rhs[i] {
            continue
        }
        return values.firstIndex(of: lhs[i])! < values.firstIndex(of: rhs[i])!
    }
    return false
}

struct Bid {
    let hand: Hand
    let bid: Int
}

extension Hand: Comparable {
    static func < (lhs: Hand, rhs: Hand) -> Bool {
        if lhs.type.rawValue == rhs.type.rawValue {
            // if lhs.typeWithoutJoker.rawValue == rhs.typeWithoutJoker.rawValue {
                 return compareHands(lhs: lhs.cards, rhs: rhs.cards)
            // }
            // return lhs.typeWithoutJoker.rawValue < rhs.typeWithoutJoker.rawValue
        }
        return lhs.type.rawValue < rhs.type.rawValue
    }
}

extension Bid: Comparable {
    static func < (lhs: Bid, rhs: Bid) -> Bool {
        return lhs.hand < rhs.hand
    }
}

@main
struct Day07: ParsableCommand {
  @Option(help: "Specify the input")
  public var input: String

  func typeWithoutJoker(_ hand: String) -> HandType {
    let cardsValues = Array(hand)
    let cardValueSet = Set(cardsValues)
    let cardValueCount = cardValueSet.map { value in
        cardsValues.filter { $0 == value }.count
    }

    let sortedCardValueCount = cardValueCount.sorted()
    let isFiveOfKind = sortedCardValueCount == [5]
    let isFourOfKind = sortedCardValueCount == [1, 4]
    let isFullHouse = sortedCardValueCount == [2, 3]
    let isThreeOfKind = sortedCardValueCount == [1, 1, 3]
    let isTwoPairs = sortedCardValueCount == [1, 2, 2]
    let isOnePair = sortedCardValueCount == [1, 1, 1, 2]
    let isHighCard = sortedCardValueCount == [1, 1, 1, 1, 1]
    if isFiveOfKind {
        return .fiveOfKind
    } else if isFourOfKind {
        return .fourOfKind
    } else if isFullHouse {
        return .fullHouse
    } else if isThreeOfKind {
        return .threeOfKind
    } else if isTwoPairs {
        return .twoPairs
    } else if isOnePair {
        return .onePair
    } else if isHighCard {
        return .highCard
    }
    return .highCard
  }

  func typeWithJoker(_ hand: String) -> HandType {
    let cardsValues = Array(hand).filter { $0 != "J" }
    let cardValueSet = Set(cardsValues)
    let cardValueCount = cardValueSet.map { value in
        cardsValues.filter { $0 == value }.count
    }

    let jokerCount = Array(hand).filter { $0 == "J" }.count

    let sortedCardValueCount = cardValueCount.sorted()
    let isFiveOfKind = sortedCardValueCount == [5] 
        || sortedCardValueCount ==  [5 - jokerCount] 
        || sortedCardValueCount == []
    let isFourOfKind = sortedCardValueCount == [1, 4] || sortedCardValueCount == [1, 4 - jokerCount]
    let isFullHouse = sortedCardValueCount == [2, 3] || sortedCardValueCount == [2, 3 - jokerCount]
    let isThreeOfKind = sortedCardValueCount == [1, 1, 3] || sortedCardValueCount == [1, 1, 3 - jokerCount]
    let isTwoPairs = sortedCardValueCount == [1, 2, 2] || sortedCardValueCount == [1, 2 - jokerCount, 2]
    let isOnePair = sortedCardValueCount == [1, 1, 1, 2] || sortedCardValueCount == [1, 1, 1, 2 - jokerCount]
    let isHighCard = sortedCardValueCount == [1, 1, 1, 1, 1]
    if isFiveOfKind {
        return .fiveOfKind
    } else if isFourOfKind {
        return .fourOfKind
    } else if isFullHouse {
        return .fullHouse
    } else if isThreeOfKind {
        return .threeOfKind
    } else if isTwoPairs {
        return .twoPairs
    } else if isOnePair {
        return .onePair
    } else if isHighCard {
        return .highCard
    }
    return .highCard
  }

  public func run() throws {
    guard let filecontent = try? String(contentsOfFile: input, encoding: .utf8)
    else {
        print("Failed to open file \(input)")
        return
    }

    let lines = filecontent.components(separatedBy: .newlines)
    var bids: [Bid] = []
    for line in lines {
        let cards = line.components(separatedBy: " ")
        let typeWithouthJoker = typeWithoutJoker(cards[0])
        let typeWithJoker = typeWithJoker(cards[0])
        let hand = Hand(cards: cards[0], type: typeWithJoker, typeWithoutJoker: typeWithouthJoker)
        bids.append(Bid(hand: hand, bid: Int(cards[1])!))
    }
    bids.sort()
    var result = 0
    for i in 0..<bids.count {
        print(bids[i].hand.cards)
        result += bids[i].bid * (i+1)
    }

    print(result)
  }
}
