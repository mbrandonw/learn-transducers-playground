reduce(xs, 0, (+) |> filtering(isPrime) |> mapping(incr) |> mapping(square))
