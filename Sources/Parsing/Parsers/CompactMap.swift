extension Parser {
  /// Returns a parser that outputs the non-`nil` results of calling the given closure with the
  /// output of this parser.
  ///
  /// This method is similar to `Sequence.compactMap` in the Swift standard library, as well as
  /// `Publisher.compactMap` in the Combine framework.
  ///
  ///     let evenParser = Int.parser().compactMap { $0.isMultiple(of: 2) }
  ///     var input = "124 hello world"[...].utf8
  ///     let output = evenParser.parse(&input) // 124
  ///     input // " hello world"
  ///
  /// - Parameter transform: A closure that accepts output of this parser as its argument and
  ///   returns an optional value.
  /// - Returns: A parser that outputs the non-`nil` result of calling the given transformation
  ///   with the output of this parser.
  @inlinable
  public func compactMap<NewOutput>(
    _ transform: @escaping (Output) -> NewOutput?
  ) -> Parsers.CompactMap<Self, NewOutput> {
    .init(upstream: self, transform: transform)
  }
}

extension Parsers {
  /// A parser that outputs the non-`nil` results of calling the given transformation with the
  /// output of its upstream parser.
  ///
  /// Returned from the `Parser.compactMap(_:)` method.
  public struct CompactMap<Upstream, Output>: Parser where Upstream: Parser {
    public let upstream: Upstream
    public let transform: (Upstream.Output) -> Output?

    @inlinable
    public init(
      upstream: Upstream,
      transform: @escaping (Upstream.Output) -> Output?
    ) {
      self.upstream = upstream
      self.transform = transform
    }

    @inlinable
    public func parse(_ input: inout Upstream.Input) async -> Output? {
      let original = input
      guard let newOutput = await self.upstream.parse(&input).flatMap(self.transform)
      else {
        input = original
        return nil
      }
      return newOutput
    }
  }
}
