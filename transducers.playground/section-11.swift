let xs = Array(2...100)

func square (n: Int) -> Int { 
  return n * n
}

func incr (n: Int) -> Int {
  return n + 1
}

xs |> fmap(square) |> fmap(incr)