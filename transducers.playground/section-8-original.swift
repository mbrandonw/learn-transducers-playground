let nums = [1.0, 3.0, 4.0, 5.5]

nums |> fmap(sqrt) |> fmap(cos) |> fmap(exp)
nums |> fmap(sqrt |> cos |> exp)
