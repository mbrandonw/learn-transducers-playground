func filter <A> (p: A -> Bool) -> [A] -> [A] {
  return {xs in
    return xs.reduce([]) {accum, x in
      if p(x) {
        return accum + [x]
      } else {
        return accum
      }
    }
  }
}