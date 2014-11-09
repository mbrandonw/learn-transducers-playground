func isTwinPrime (p: Int) -> Bool {
  return isPrime(p) && isPrime(p+2)
}