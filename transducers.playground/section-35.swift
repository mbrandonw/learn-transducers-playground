func taking <A, C> (n: Int) -> (([C], A) -> [C]) -> (([C], A) -> [C]) {
  return { reducer in
    return { accum, x in
      if accum.count < n {
        return reducer(accum, x)
      } else {
        return accum
      }
    }
  }
}