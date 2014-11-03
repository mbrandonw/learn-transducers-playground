// x |> f = f(x)
infix operator |> {associativity left}
func |> <A, B> (x: A, f: A -> B) -> B {
  return f(x)
}

// (f |> g)(x) = f(g(x))
func |> <A, B, C> (f: A -> B, g: B -> C) -> A -> C {
  return { g(f($0)) }
}
