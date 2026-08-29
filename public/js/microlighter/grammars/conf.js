// Not shipped by microlighter. The `conf` blocks on this site are a grab bag
// (a cache manifest, a mail template, a regex), so this stays deliberately
// conservative: only unambiguous config shapes get colour.
export default {
  scopeName: "source.conf",
  patterns: [
    { include: "#comments" },
    { include: "#sections" },
    { include: "#settings" },
    { include: "#strings" },
    { include: "#booleans" },
    { include: "#numbers" }
  ],
  repository: {
    comments: {
      match: "^\\s*[#;].*$",
      name: "comment.line"
    },
    sections: {
      match: "^\\s*\\[[^\\]\\n]+\\]\\s*$",
      name: "entity.name.section"
    },
    settings: {
      match: "^\\s*([\\w.-]+)\\s*(=|:)",
      captures: {
        1: { name: "entity.name.key" },
        2: { name: "keyword.operator" }
      }
    },
    strings: {
      match: "\"[^\"\\n]*\"",
      name: "string.quoted.double"
    },
    booleans: {
      match: "\\b(?:true|false|on|off|yes|no)\\b",
      name: "constant.language.boolean"
    },
    numbers: {
      match: "(?<![\\w.])\\d+(?:\\.\\d+)?\\b",
      name: "constant.numeric"
    }
  }
};
