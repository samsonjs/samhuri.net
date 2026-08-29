// Not shipped by microlighter. Scoped to the Lisp on this site: Emacs Lisp
// from the 2007 editor posts plus a couple of Arc REPL transcripts.
export default {
  scopeName: "source.lisp",
  patterns: [
    { include: "#comments" },
    { include: "#strings" },
    { include: "#definition" },
    { include: "#keywords" },
    { include: "#characters" },
    { include: "#quoted-symbols" },
    { include: "#keyword-symbols" },
    { include: "#numbers" },
    { include: "#operators" }
  ],
  repository: {
    comments: {
      match: ";.*$",
      name: "comment.line.semicolon"
    },
    strings: {
      match: "\"(?:\\\\.|[^\"\\\\])*\"",
      name: "string.quoted.double"
    },
    definition: {
      match: "(?<=\\()((?:cl-)?def(?:un|macro|var|const|custom|subst|group|face|alias|advice))\\s+([^\\s()]+)",
      captures: {
        1: { name: "storage.type.function" },
        2: { name: "entity.name.function" }
      }
    },
    keywords: {
      match: "(?<=\\()(?:lambda|let\\*?|if|when|unless|cond|case|and|or|not|progn|prog1|prog2|setq|setf|while|dolist|dotimes|save-excursion|save-restriction|with-current-buffer|interactive|require|provide|quote|function|catch|throw|unwind-protect|condition-case|ignore-errors|declare|do|def|mac|w/uniq)(?=[\\s()])",
      name: "keyword.control"
    },
    characters: {
      match: "\\?(?:\\\\[A-Za-z-]+|\\\\.|\\S)",
      name: "constant.character"
    },
    "quoted-symbols": {
      match: "'[A-Za-z_][\\w*/+=<>!?-]*",
      name: "constant.other.symbol"
    },
    "keyword-symbols": {
      match: ":[A-Za-z_][\\w*/+=<>!?-]*",
      name: "constant.other.symbol"
    },
    numbers: {
      match: "(?<![\\w.-])-?(?:\\d+\\.\\d+|\\d+)(?![\\w-])",
      name: "constant.numeric"
    },
    operators: {
      match: "[`,@]|#'",
      name: "keyword.operator"
    }
  }
};
