reduce(xs, [], append |> filtering(isprime) |> mapping(incr) |> mapping(square))

filter(isprime)( xs |> fmap(square |> incr) )