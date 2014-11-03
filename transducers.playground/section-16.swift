// Simple function to check primality of an integer. Details of this
// function aren't important.
func isprime (p: Int) -> Bool {
  if p == 2 { return true }
  for i in 2...Int(sqrtf(Float(p))) {
    if p % i == 0 {
      return false
    }
  }
  return true
}

filter(isprime)( xs |> fmap(square |> incr) )
