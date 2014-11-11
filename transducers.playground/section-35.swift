func taking <A, C> (n: Int) -> (([C], A) -> [C]) -> (([C], A) -> [C]) {
  return { reducer in
    return { accum, x in
      return accum.count < n ? reducer(accum, x) : accum
    }
  }
}