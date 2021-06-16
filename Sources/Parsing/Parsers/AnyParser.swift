extension Parser {
  /// Wraps this parser with a type eraser.
  ///
  /// This form of _type erasure_ preserves abstraction across API boundaries, such as different
  /// modules.
  ///
  /// When you expose your composed parsers as the `AnyParser` type, you can change the underlying
  /// implementation over time without affecting existing clients.
  ///
  /// - Returns: An `AnyPublisher` wrapping this publisher.
  @inlinable
  public func eraseToAnyParser() -> AnyParser<Input, Output> {
    .init(self)
  }
}

/// A type-erased parser of `Output` from `Input`.
///
/// This parser forwards its `parse()` method to an arbitrary underlying parser having the same
/// `Input` and `Output` types, hiding the specifics of the underlying `Parser`.
///
/// Use `AnyParser` to wrap a publisher whose type has details you don't want to expose across API
/// boundaries, such as different modules. When you use type erasure this way, you can change the
/// underlying parser over time without affecting existing clients.
public struct AnyParser<Input, Output>: Parser {
  @usableFromInline
  let parser: (inout Input) async -> Output?

  /// Creates a type-erasing parser to wrap the given parser.
  ///
  /// - Parameter parser: A parser to wrap with a type eraser.
  @inlinable
  public init<P>(_ parser: P) where P: Parser, P.Input == Input, P.Output == Output {
    self.init(parser.parse)
  }

  /// Creates a parser that wraps the given closure in its `parse()` method.
  ///
  /// - Parameter parse: A closure that attempts to parse an output from an input. `parse` is
  ///   executed each time the `parse()` method is called on the resulting parser.
  @inlinable
  public init(_ parse: @escaping (inout Input) async -> Output?) {
    self.parser = parse
  }

  @inlinable
  public func parse(_ input: inout Input) async -> Output? {
    await self.parser(&input)
  }

  @inlinable
  public func eraseToAnyParser() -> Self {
    self
  }
}

extension Parsers {
  public typealias AnyParser = Parsing.AnyParser  // NB: Convenience type alias for discovery
}
