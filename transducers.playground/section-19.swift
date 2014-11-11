func mapping <A, B, C> (f: A -> B) -> ((C, B) -> C) -> ((C, A) -> C) {
  return { reducer in
    return { accum, x in reducer(accum, f(x)) }
  }
}