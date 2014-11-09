reduce(1...200, [],
  append |> filtering(isTwinPrime) 
         |> mapping(incr) 
         |> mapping(square)
         |> taking(10))