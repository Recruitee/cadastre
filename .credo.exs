%{
  configs: [
    %{
      name: "default",
      strict: true,
      files: %{
        included: ["dev/", "lib/", "test/"]
      },
      checks: [
        {Credo.Check.Refactor.MapInto, false},
        {Credo.Check.Warning.LazyLogging, false}
      ]
    }
  ]
}
