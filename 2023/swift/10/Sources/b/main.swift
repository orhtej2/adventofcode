import ArgumentParser
import DequeModule
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

  func perpendicular() -> [Direction] {
    switch self {
    case .south:
      return [.west, .east]
    case .north:
      return [.east, .west]
    case .west:
      return [.north, .south]
    case .east:
      return [.south, .north]
    }
  }
}

enum RotationDirection: Int {
  case clockwise = 0
  case counterclockwise = 1
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
      if start.1 + coordDiffs.1 < 0 || start.1 + coordDiffs.1 >= map.count {
        continue
      }
      if start.0 + coordDiffs.0 < 0 || start.0 + coordDiffs.0 >= map[0].count {
        continue
      }
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
    let startExits = findExits(map, start)
    var exits = startExits
    print("Start is \(start)")
    var current = start
    var clockwise = 0
    var counterclockwise = 0
    var prevDirection = exits[0]
    var starters = [Coord: [Direction]]()
    repeat {
      current = add(current, exits[0].coordDiff())
      if current == start {
        break
      }
      exits[0] = map[current.1][current.0].directions.first(where: { $0 != exits[0].opposite() })!
      if exits[0] != prevDirection {
        starters[Coord(current)] = [prevDirection, exits[0]]
        if exits[0] == prevDirection.perpendicular()[0] {
          clockwise += 1
        } else {
          counterclockwise += 1
        }
      } else {
          starters[Coord(current)] = [exits[0]]
      }
      prevDirection = exits[0]
    } while true

    if exits[1] != prevDirection {
      if exits[1] == prevDirection.perpendicular()[0] {
        clockwise += 1
      } else {
        counterclockwise += 1
      }
    }
    // if startExits[1] != startExits[0] {
    //   starters[Coord(start)] = startExits
    // }

    print("Clockwise is \(clockwise)")
    print("Counterclockwise is \(counterclockwise)")

    var direction = RotationDirection.clockwise
    if counterclockwise > clockwise {
      direction = .counterclockwise
    }

    var trueStarters = Deque<(Coord, Direction)>()

    for (coord, startDirection) in starters {
      for d1 in startDirection {
        let d = d1.perpendicular()[direction.rawValue]
        let c = add((coord.x, coord.y), d.coordDiff())
        if c.0 < 0 || c.0 >= map[0].count || c.1 < 0 || c.1 >= map.count {
          continue
        }
        if map[c.1][c.0].type == .ground {
          trueStarters.append((Coord(c), d))
        }
      }
    }

    var result = 0
    var seen = Set<Coord>()
    while !trueStarters.isEmpty {
      let (current, currentDirection) = trueStarters.popFirst()!
      if seen.insert(current).inserted {
        result += 1
      }
      let next = add((current.x, current.y), currentDirection.coordDiff())
      if next.1 >= 0 && next.1 < map.count
        && next.0 >= 0 && next.0 < map[0].count
        && map[next.1][next.0].type == .ground {
        trueStarters.append((Coord(next), currentDirection))
      }
    }
    print(result)

    for (y, line) in map.enumerated() {
      for (x, cell) in line.enumerated() {
        if (seen.contains(Coord((x, y)))) {
          print("O", terminator: "")
          continue
        }
        let d = starters[Coord((x, y))]
        if d != nil {
          if (d!.count == 2) {
            print("x", terminator: "")
          } else {
            let d2 = d![0].perpendicular()[direction.rawValue]
            switch d2 {
            case .north:
              print("^", terminator: "")
            case .south:
              print("v", terminator: "")
            case .west:
              print("<", terminator: "")
            case .east:
              print(">", terminator: "")
            }
          }
          continue
        }
        switch cell.type {
        case .ground:
          print(".", terminator: "")
        case .pipe:
          print("|", terminator: "")
        case .start:
          print("S", terminator: "")
        }
      }
      print("")
    }
  }
}
