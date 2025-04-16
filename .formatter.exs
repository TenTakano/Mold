locals_without_parans = [
  req: 2,
  opt: 2
]

[
  locals_without_parens: locals_without_parans,
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  export: [
    locals_without_parens: locals_without_parans
  ]
]
