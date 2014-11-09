reduce(xs, [], append |> filtering(isprime) |> mapping(incr) |> mapping(square))

xs |> fmap(square |> incr) |> filter(isprime)
