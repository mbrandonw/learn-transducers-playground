reduce(xs, [], append |> filtering(isPrime) |> mapping(incr) |> mapping(square))

xs |> fmap(square |> incr) |> filter(isPrime)