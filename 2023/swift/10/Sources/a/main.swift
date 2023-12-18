import ArgumentParser
import Foundation

enum Direction: Int {
  case south = 0
  case north = 1
  case west = 2
  case east = 3
}

extension Direction {
  func coordDiff() -> (Int, Int) {
    switch self {
    case .south:
      return (0, 1)
    case .north:
      return (0, -1)
    case .west:
      return (-1, 0)
    case .east:
      return (1, 0)
    }
  }

  func opposite() -> Direction {
    switch self {
    case .south:
      return .north
    case .north:
      return .south
    case .west:
      return .east
    case .east:
      return .west
    }
  }
}

struct Coord: Hashable {
  let x: Int
  let y: Int

  init(_ coord: (Int, Int)) {
    self.x = coord.0
    self.y = coord.1
  }
}

@main
struct Day10: ParsableCommand {
  @Option(help: "Specify the input")
  public var input: String

  enum CellType: Int {
    case ground = 0
    case pipe = 1
    case start = 2
  }

  struct Cell {
    let type: CellType
    let directions: [Direction]
  }

  func getCell(_ element: String.Element) -> Cell {
    switch element {
    case ".":
      return Cell(type: .ground, directions: [])
    case "|":
      return Cell(type: .pipe, directions: [.north, .south])
    case "-":
      return Cell(type: .pipe, directions: [.west, .east])
    case "F":
      return Cell(type: .pipe, directions: [.south, .east])
    case "7":
      return Cell(type: .pipe, directions: [.south, .west])
    case "L":
      return Cell(type: .pipe, directions: [.north, .east])
    case "J":
      return Cell(type: .pipe, directions: [.north, .west])
    case "S":
      return Cell(type: .start, directions: [])
    default:
        return Cell(type: .ground, directions: [])
    }
  }

  func findStart(_ map: [[Cell]]) -> (Int, Int) {
    for (y, line) in map.enumerated() {
      for (x, cell) in line.enumerated() {
        if cell.type == .start {
          return (x, y)
        }
      }
    }
    return (-1, -1)
  }

  func findExits(_ map: [[Cell]], _ start: (Int, Int)) -> [Direction] {
    var exits = [Direction]()
    for coordDiffs in [(1, 0), (0, 1), (-1, 0), (0, -1)] {
      for direction in map[start.1 + coordDiffs.1][start.0 + coordDiffs.0].directions
        where direction.opposite().coordDiff() == coordDiffs {
          exits.append(direction.opposite())
          break
        }
    }

    return exits
  }

  func add(_ a: (Int, Int), _ b: (Int, Int)) -> (Int, Int) {
    return (a.0 + b.0, a.1 + b.1)
  }

  public func run() throws {
    guard let filecontent = try? String(contentsOfFile: input, encoding: .utf8)
    else {
        print("Failed to open file \(input)")
        return
    }

    let lines = filecontent.components(separatedBy: .newlines)
    let map = lines.map { line in
      line.map { element in
        getCell(element)
      }
    }
    let start = findStart(map)
    var exits = findExits(map, start)
    var first = start
    var second = start
    print("Start is \(start)")

    var result = 0
    var seen = Set<Coord>()
    repeat {
        print(first)
        print(second)
        print(exits)

        result += 1
        first = add(first, exits[0].coordDiff())
        exits[0] = map[first.1][first.0].directions.first(where: { $0 != exits[0].opposite() })!
        seen.insert(Coord(first))

        second = add(second, exits[1].coordDiff())
        exits[1] = map[second.1][second.0].directions.first(where: { $0 != exits[1].opposite() })!
    } while first != second && seen.contains(Coord(second)) == false
    print("Result is \(result)")
  }
}
