// Not shipped by microlighter. Scoped to the Haskell that appears on this site:
// the Scheme-interpreter series from 2007, which is plain Haskell 98 with type
// signatures, ADTs, guards, do-notation, and Parsec combinators.
export default {
  scopeName: "source.haskell",
  patterns: [
    { include: "#comments" },
    { include: "#strings" },
    { include: "#characters" },
    { include: "#imports" },
    { include: "#declarations" },
    { include: "#type-signature" },
    { include: "#keywords" },
    { include: "#definition" },
    { include: "#booleans" },
    { include: "#constructors" },
    { include: "#numbers" },
    { include: "#infix-backticks" },
    { include: "#operators" }
  ],
  repository: {
    comments: {
      patterns: [
        { begin: "\\{-", end: "-\\}", name: "comment.block" },
        // A run of three or more dashes is a valid operator, so only treat
        // exactly `--` followed by a non-operator character as a comment.
        { match: "--(?![!#$%&*+./<=>?@\\\\^|~:-]).*$", name: "comment.line.double-dash" }
      ]
    },
    strings: {
      match: "\"(?:\\\\.|[^\"\\\\])*\"",
      name: "string.quoted.double"
    },
    // Requires a closing quote on the same token so identifier primes (`xs'`)
    // are left alone.
    characters: {
      match: "'(?:\\\\(?:[A-Za-z]+|\\d+|.)|[^'\\\\])'",
      name: "string.quoted.single"
    },
    imports: {
      match: "^\\s*(module|import)\\s+(qualified\\s+)?([A-Z][\\w.']*)",
      captures: {
        1: { name: "keyword.control.import" },
        2: { name: "keyword.control" },
        3: { name: "entity.name.type" }
      }
    },
    declarations: {
      match: "^\\s*(data|newtype|type|class|instance)\\b(?:\\s+([A-Z][\\w']*))?",
      captures: {
        1: { name: "storage.type" },
        2: { name: "entity.name.type" }
      }
    },
    "type-signature": {
      match: "^\\s*(\\(?[a-z_][\\w']*\\)?)\\s*(::)",
      captures: {
        1: { name: "entity.name.function" },
        2: { name: "keyword.operator" }
      }
    },
    keywords: {
      match: "\\b(?:case|of|do|if|then|else|let|in|where|deriving|forall|infix|infixl|infixr|hiding|as|qualified)\\b",
      name: "keyword.control"
    },
    // In Haskell an unindented lowercase identifier starts an equation, so
    // column zero is a good enough stand-in for real definition parsing.
    definition: {
      match: "^([a-z_][\\w']*)(?=\\s)",
      name: "entity.name.function"
    },
    booleans: {
      match: "\\b(?:True|False)\\b",
      name: "constant.language.boolean"
    },
    // Capitalised names are constructors, types, or modules in every position.
    constructors: {
      match: "\\b[A-Z][\\w']*",
      name: "entity.name.type"
    },
    numbers: {
      match: "(?<![\\w.'])(?:0[xX][0-9a-fA-F]+|0[oO][0-7]+|\\d+(?:\\.\\d+)?(?:[eE][+-]?\\d+)?)\\b",
      name: "constant.numeric"
    },
    "infix-backticks": {
      match: "`[A-Za-z_][\\w'.]*`",
      name: "keyword.operator"
    },
    operators: {
      match: "(?:::|->|<-|=>|<\\|>|>>=|>>|\\+\\+|==|/=|<=|>=|&&|\\|\\||\\.\\.|[-+*/$.@\\\\|<>=:^~!])",
      name: "keyword.operator"
    }
  }
};
