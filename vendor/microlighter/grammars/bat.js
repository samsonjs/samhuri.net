// Not shipped by microlighter. Scoped to the Windows batch on this site: the
// 2006 Boot Camp / Parallels activation script and its command-line snippets.
export default {
  scopeName: "source.batchfile",
  patterns: [
    { include: "#comments" },
    { include: "#strings" },
    { include: "#labels" },
    { include: "#echo-off" },
    { include: "#keywords" },
    { include: "#commands" },
    { include: "#variables" },
    { include: "#switches" },
    { include: "#numbers" },
    { include: "#operators" }
  ],
  repository: {
    comments: {
      match: "^\\s*(?:@?[Rr][Ee][Mm]\\b|::).*$",
      name: "comment.line"
    },
    strings: {
      match: "\"[^\"\\n]*\"",
      name: "string.quoted.double"
    },
    labels: {
      match: "^\\s*:[A-Za-z_][\\w.-]*",
      name: "entity.name.function"
    },
    "echo-off": {
      match: "^\\s*@",
      name: "keyword.operator"
    },
    keywords: {
      match: "\\b(?:[Ii][Ff]|[Ee][Ll][Ss][Ee]|[Ff][Oo][Rr]|[Ii][Nn]|[Dd][Oo]|[Gg][Oo][Tt][Oo]|[Cc][Aa][Ll][Ll]|[Ee][Xx][Ii][Tt]|[Ss][Ee][Tt]|[Ss][Ee][Tt][Ll][Oo][Cc][Aa][Ll]|[Ee][Nn][Dd][Ll][Oo][Cc][Aa][Ll]|[Dd][Ee][Ff][Ii][Nn][Ee][Dd]|[Nn][Oo][Tt]|[Ee][Xx][Ii][Ss][Tt]|[Ee][Rr][Rr][Oo][Rr][Ll][Ee][Vv][Ee][Ll]|[Ee][Qq][Uu]|[Nn][Ee][Qq]|[Ll][Ss][Ss]|[Ll][Ee][Qq]|[Gg][Tt][Rr]|[Gg][Ee][Qq])\\b",
      name: "keyword.control"
    },
    commands: {
      match: "\\b(?:echo|copy|xcopy|move|del|erase|mkdir|md|rmdir|rd|dir|cd|chdir|type|ren|rename|find|findstr|attrib|cls|pause|start|title|ping|ipconfig|net|reg|tasklist|taskkill|shutdown|sc)\\b",
      name: "support.function.builtin"
    },
    // Environment expansion, delayed expansion, and `for` loop parameters.
    variables: {
      match: "%%?[A-Za-z_][\\w]*%?|%~?\\d|![A-Za-z_][\\w]*!",
      name: "variable.other"
    },
    switches: {
      match: "(?<=\\s)/[A-Za-z?][\\w:-]*",
      name: "constant.language.option"
    },
    numbers: {
      match: "(?<![\\w.])\\d+(?![\\w.])",
      name: "constant.numeric"
    },
    operators: {
      match: ">>|>|<|\\|\\||&&|\\||&|==",
      name: "keyword.operator"
    }
  }
};
