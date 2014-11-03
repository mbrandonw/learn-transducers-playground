func map_from_reduce <A, B> (f: A -> B) -> [A] -> [B] {
  return {xs in 
    return xs.reduce([]) { accum, x in accum + [f(x)] }
  }
}

func filter_from_reduce <A> (p: A -> Bool) -> [A] -> [A] {
  return {xs in
    return xs.reduce([]) { accum, x in 
      if p(x) {
        return accum + [x]
      } else {
        return accum
      }
    }
  }
}

func take_from_reduce <A> (n: Int) -> [A] -> [A] {
  return {xs in
    return xs.reduce([]) { accum, x in
      if accum.count < n {
        return accum + [x]
      } else {
        return accum
      }
    }
  }
}

map_from_reduce(sqrt)([1.0, 2.0, 3.0])

filter_from_reduce(isfinite)([1.0, 2.0, 3.0, 1.0/0.0])

take_from_reduce(5)([1, 2, 3, 4, 5, 6, 7, 8])
