// Not shipped by microlighter. Scoped to the Scheme on this site: small R5RS
// snippets from the elschemo posts and their REPL transcripts.
export default {
  scopeName: "source.scheme",
  patterns: [
    { include: "#comments" },
    { include: "#strings" },
    { include: "#definition" },
    { include: "#keywords" },
    { include: "#booleans" },
    { include: "#characters" },
    { include: "#quoted-symbols" },
    { include: "#numbers" },
    { include: "#operators" }
  ],
  repository: {
    comments: {
      patterns: [
        { begin: "#\\|", end: "\\|#", name: "comment.block" },
        { match: ";.*$", name: "comment.line.semicolon" }
      ]
    },
    strings: {
      match: "\"(?:\\\\.|[^\"\\\\])*\"",
      name: "string.quoted.double"
    },
    // Covers both `(define name ...)` and `(define (name args) ...)`.
    definition: {
      match: "(\\(define(?:-syntax|-record-type)?)\\s+\\(?\\s*([^\\s()]+)",
      captures: {
        1: { name: "storage.type.function" },
        2: { name: "entity.name.function" }
      }
    },
    keywords: {
      match: "(?<=\\()(?:lambda|named-lambda|let\\*?|letrec\\*?|let-values|if|cond|else|case|and|or|not|begin|do|when|unless|delay|force|set!|quote|quasiquote|unquote|define-syntax|let-syntax|syntax-rules|call-with-current-continuation|call/cc)(?=[\\s()])",
      name: "keyword.control"
    },
    booleans: {
      match: "#(?:t|f|true|false)\\b",
      name: "constant.language.boolean"
    },
    characters: {
      match: "#\\\\(?:[A-Za-z]+|.)",
      name: "constant.character"
    },
    "quoted-symbols": {
      match: "'[A-Za-z_][\\w*/+=<>!?-]*",
      name: "constant.other.symbol"
    },
    numbers: {
      match: "(?<![\\w.-])-?(?:\\d+\\.\\d+|\\d+/\\d+|\\d+)(?![\\w-])",
      name: "constant.numeric"
    },
    operators: {
      match: "[`,@]|(?<=\\()[-+*/<>=]+(?=[\\s()])",
      name: "keyword.operator"
    }
  }
};
