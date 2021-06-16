/// A parser that waits for a call to its `parse` method before running the given closure to
/// create a parser for the given input.
public final class Lazy<LazyParser>: Parser where LazyParser: Parser {
  @usableFromInline
  internal var lazyParser: LazyParser?

  public let createParser: () -> LazyParser

  @inlinable
  public init(createParser: @escaping () -> LazyParser) {
    self.createParser = createParser
  }

  @inlinable
  public func parse(_ input: inout LazyParser.Input) async -> LazyParser.Output? {
    guard let parser = self.lazyParser else {
      let parser = self.createParser()
      self.lazyParser = parser
      return await parser.parse(&input)
    }
    return await parser.parse(&input)
  }
}

extension Parsers {
  public typealias Lazy = Parsing.Lazy  // NB: Convenience type alias for discovery
}
