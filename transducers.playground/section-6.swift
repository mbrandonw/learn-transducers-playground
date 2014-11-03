func fmap <A, B> (f: A -> B) -> [A] -> [B] {
  return { map($0, f) }
}
