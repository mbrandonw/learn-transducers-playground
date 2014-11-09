reduce(xs, [], append |> mapping(incr) |> mapping(square))

xs |> fmap(square |> incr)
