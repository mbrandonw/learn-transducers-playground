## Transducers

Transducers provide a nice way of efficiently processing arrays (and list-like types) by combining many operations into a single one. To illustrate this we will come up with a situation where the naive way of mapping and filtering an array of integers has some obvious flaws, and then look at how we can remedy it.

Before we get to that we need to build up some tools to make function composition a little nicer. Afterall, bolstering function composition is one of the most important properties of functional programming. Here are a few simple combinators to start things off with:

```swift
// x |> f = f(x)
infix operator |> {associativity left}
func |> <A, B> (x: A, f: A -> B) -> B {
  return f(x)
}

// (f |> g)(x) = f(g(x))
func |> <A, B, C> (f: A -> B, g: B -> C) -> A -> C {
  return { g(f($0)) }
}
```

Using these combinators we can now be way more expressive with the flow of data:

```swift
import Foundation

4.0 |> sqrt |> cos |> exp

// compare with:
exp(cos(sqrt(4.0)))
```

We will also re-define `map` to have a signature that is easier to work with:

```swift
func fmap <A, B> (f: A -> B) -> [A] -> [B] {
  return { map($0, f) }
}
```

This signature makes it clear that `map` simply lifts a function `A -> B` to a function `[A] -> [B]`. For example:

```swift
let nums = [1.0, 3.0, 4.0, 5.5]

nums |> fmap(sqrt) |> fmap(cos) |> fmap(exp)
nums |> fmap(sqrt |> cos |> exp)
```

Finally, we need to re-define `filter` just like we did for `map`:

```swift
func filter <A> (p: A -> Bool) -> [A] -> [A] {
  return {xs in
    var ys = [A]()
    for x in xs {
      if p(x) { ys.append(x) }
    }
    return ys
  }
}
```

This signature helps clarify that `filter` simply lifts a predicate `A -> Bool` to a function on arrays `[A] -> [A]`.

Using these combinators and array processing functions we can do all types of fun stuff. Let's take a large array of integers and run them through a few functions:

```swift
let xs = Array(1...100)

func square (n: Int) -> Int { 
  return n * n
}

func incr (n: Int) -> Int {
  return n + 1
}

xs |> fmap(square) |> fmap(incr)
```

This isn't very efficient because we know that this will process the array of `xs` twice: once to `square` and again to `incr`. Instead we could compose `square` and `incr` once and feed that into `fmap`:

```swift
xs |> fmap(square |> incr)
```

Now we are simultaneously squaring and incrementing the `xs` in a single pass. What if we then wanted to `filter` that array of numbers to find all of the primes?

```swift
// Simple function to check primality of an integer. Details of this
// function aren't important, but it works.
func isprime (p: Int) -> Bool {
  if p == 2 { return true }
  for i in 2...Int(sqrtf(Float(p))) {
    if p % i == 0 { return false }
  }
  return true
}

filter(isprime)( xs |> fmap(square |> incr) )
```

We're back to being inefficient again since we are processing the `xs` twice: once to `square` and `incr`, and again to check `isprime`.

Transducers aim to remedy this by collecting all mapping and filtering functions into a single function that can be run once to process the `xs`. The idea stems from the observation that most of the functions we write for processing arrays can actually be written in terms of `reduce`. (In fact, one can make a precise statement about *all* array functions being rewritten as `reduce`.) 

For example, here is how one might write `map`, `filter` and `take` in terms of `reduce`:

```swift
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

[1.0, 2.0, 3.0] |> map_from_reduce(sqrt)

[1.0, 2.0, 3.0, 1.0/0.0] |> filter_from_reduce(isfinite)

[1, 2, 3, 4, 5, 6, 7, 8] |> take_from_reduce(5)
```

Now that we know `reduce` is in some sense "universal" among functions that process arrays we can try unifying all of our array processing under `reduce` and see if that aids in composition. To get to that point we are going to define some more things. First a term: given data types `A` and `C` we call a function of the form `(C, A) -> C` a **reducer** on `A`. These are precisely the kinds of functions we could feed into `reduce`. The first argument is called the **accumulation** and the second element is just the element of the array being inspected. A function that takes a reducer on `A` and returns a reducer on `B` is called a **transducer**. A simple example would be the following:

```swift
func mapping <A, B, C> (f: A -> B) -> ((C, B) -> C) -> ((C, A) -> C) {
  return { reducer in
    return { accum, x in
      return reducer(accum, f(x))
    }
  }
}
```

It takes any function `A -> B` and lifts it to a transducer from `B` to `A`. It is very important to note that the direction changed! This is called contravariance. Note that the implementation of this function is pretty much the only thing we could do to make it compile. It is almost as if the compiler is writing it for us. 

Another example:

```swift
func filtering <A, C> (p: A -> Bool) -> ((C, A) -> C) -> (C, A) -> C {
  return { reducer in
    return { accum, x in
      return p(x) ? reducer(accum, x) : accum
    }
  }
}
```

This lifts a predicate `A -> Bool` to a transducer from `A` to `A`.

We can use these functions to lift functions and predicates to transducers, and then feed them into `reduce`. In particular, consider `mapping(square)`. That lifts `square` to a transducer `((C, Int) -> C) -> ((C, Int) -> C)`, where `C` can be any data type. If we feed a reducer into `mapping(square)` we get another reducer. A simple reducer that comes up often when dealing with arrays is `append`, which Swift doesn't have natively implemented but we can do easily enough:

```swift
func append <A> (xs: [A], x: A) -> [A] {
  return xs + [x]
}

append([1, 2, 3, 4], 5)
```

Then what does `mapping(square)(append)` do? It just squares an integer and appends it to an array of integers.

```swift
mapping(square)(append)([1, 2, 3, 4], 5)
```

Feeding the reducer `mapping(square)(append)` into `reduce` we see that we get the same thing had we mapped with `square`:

```swift
reduce(xs, [], mapping(square)(append))

fmap(square)(xs)
```

Ok, but now we've just made this code more verbose to seemingly accomplish the same thing. The reason to do this is because transducers are highly composable, whereas regular reducers are not. We can also do:

```swift
reduce(xs, [], append |> mapping(incr) |> mapping(square))

fmap(square |> incr)(xs)
```

Well, once again we didn't produce anything new that `map` didn't provide before. However, now we will mix in filters!

```swift
reduce(xs, [], append |> filtering(isprime) |> mapping(incr) |> mapping(square))

filter(isprime)( xs |> fmap(square |> incr) )
```

There we go. This is the first time we've written something equivalently with `reduce` and `map`, but the `reduce` way resulted in processing the `xs` a single time, whereas the `map` way needed to iterate over `xs` twice. 

Let's add another wrinkle. Say we didn't just want those primes that are of the form `n*n+1` for `2 <= n <= 100`, but we wanted to find their sum. It's a very easy change:

```swift
reduce(xs, 0, (+) |> filtering(isprime) |> mapping(incr) |> mapping(square))
```

Now that looks pretty good! Some really terrific code reusability going on right there.
