extension Parser {
  /// Returns a parser that filters output from this parser when its output does not satisfy the
  /// given predicate.
  ///
  /// - Parameter predicate: A closure that takes an output from this parser and returns a Boolean
  ///   value indicating whether the output should be returned.
  /// - Returns: A parser that filters its output.
  @inlinable
  public func filter(_ predicate: @escaping (Output) -> Bool) -> Parsers.Filter<Self> {
    .init(upstream: self, predicate: predicate)
  }
}

extension Parsers {
  /// A parser that filters the output of an upstream parser when it does not satisfy a predicate.
  public struct Filter<Upstream>: Parser where Upstream: Parser {
    public let upstream: Upstream
    public let predicate: (Upstream.Output) -> Bool

    @inlinable
    public init(upstream: Upstream, predicate: @escaping (Upstream.Output) -> Bool) {
      self.upstream = upstream
      self.predicate = predicate
    }

    @inlinable
    public func parse(_ input: inout Upstream.Input) async -> Upstream.Output? {
      let original = input
      guard
        let output = await self.upstream.parse(&input),
        self.predicate(output)
      else {
        input = original
        return nil
      }
      return output
    }
  }
}
