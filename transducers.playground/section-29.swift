reduce(xs, [], append |> mapping(incr) |> mapping(square))

fmap(square |> incr)(xs)