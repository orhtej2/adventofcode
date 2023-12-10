import ArgumentParser
import Foundation

struct MapKey: Hashable {
    let first: String
    let second: String
}

struct Seen : Hashable {
    let type: String
    let coord: Int
}

struct MapEntry {
    let input: Range<Int>
    let output: Range<Int>
}

@main
struct Day05a: ParsableCommand {
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

    let lines = filecontent.components(separatedBy: .newlines)
    let s = numbers(fromString: lines[0].substring(from: 7))
    var seeds = [Range<Int>]()
    for i in 0 ..< s.count / 2 {
      seeds.append(s[i*2]..<s[i*2]+s[i*2+1])
    }

    var mappings = [String: String]()
    var almanac = [MapKey: [MapEntry]]()

    var key: MapKey?
    for idx in 2..<lines.count {
      if lines[idx] == "" {
        key = nil
        continue
      }

      if key == nil {
        let split = lines[idx].components(separatedBy: ["-", " "])
        key = MapKey(first: split[0], second: split[2])
        mappings[split[0]] = split[2]
        almanac[key!] = []
      } else {
        let entry = numbers(fromString: lines[idx])
        almanac[key!]!.append(MapEntry(input: entry[1]..<entry[1]+entry[2], output: entry[0]..<entry[0]+entry[2]))
      }
    }

    // print(seeds)
    // print(mappings)
    // print(almanac)

    var result = Int.max
    var seen = [String: Set<Int>]()
    mappings.values.forEach({ seen[$0] = Set<Int>() })
    for seed in seeds {
      for i in seed {
        var what = i
        var first = "seed"
        var skip = false
        while let second = mappings[first] {
          // if !seen[second]!.insert(what).inserted {
          //   skip = true
          //   break
          // }
          if let entries = almanac[MapKey(first: first, second: second)] {
            for entry in entries {
              if entry.input.contains(what) {
                what = entry.output.lowerBound + (what - entry.input.lowerBound)
                break
              }
            }
          } else {
            assert(false)
          }
          first = second
        }
        // if (skip) {
        //   continue
        // }
        if what < result {
          print("New best: \(what) from \(i)")
          result = what
        }
      }
    }
    print(result)
  }
}