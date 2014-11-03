func filter <A> (p: A -> Bool) -> [A] -> [A] {
  return {xs in
    var ys = [A]()
    for x in xs {
      if (x) { ys.append(x) }
    }
    return ys
  }
}
