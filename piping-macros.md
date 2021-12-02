# Quick reference for the magic piping macros

### [Chain.jl](https://github.com/jkrumbiegel/Chain.jl)

```julia
using Chain

# Just like x |> f etc.
@chain x f == f(x)
@chain x g f == f(g(x))
@chain x begin
    a
    b
    c
    d
    e
end == e(d(c(b(a(x)))))

# Unlike |>, functions can have arguments - the value
# preceding a function will be treated as its first argument
@chain x g(y, z) f == f(g(x, y, z))
@chain x g f(y, z) == f(g(x), y, z)

# If first argument isn't right, designate a place with _
@chain x g(y, z, _) f == f(g(y, z, x))
@chain x g f(y, z, _) == f(y, z, g(x))

# Middle state of the pipeline can be inspected
@chain x begin
    a
    b
    c
    @aside println("intermediate result: $_")
    d
    e
end
```

### [Underscores.jl](https://github.com/c42f/Underscores.jl/)

```julia
using Underscores

# Extends x |> f etc.
@_ x |> f == f(x)
@_ x |> g |> f == f(g(x))
@_ x |> a |> b |> c |> d |> e == e(d(c(b(a(x)))))

# Use __ to reference the whole thing
@_ x |> g(__, y, z) |> f == f(g(x, y, z))

@_ x |> g |> f(__, y, z) == f(g(x), y, z)

@_ x |> g(y, z, __) |> f == f(g(y, z, x))

@_ x |> g |> f(y, z, __) == f(y, z, g(x))

# A single underscore make for quick lambdas
@_ data |> filter(_ > 10, __) |> map(_ + 1, __)
```

### [Lazy.jl](https://github.com/MikeInnes/Lazy.jl)

```julia
using Lazy

# Just like x |> f etc.
@> x f == f(x)
@> x g f == f(g(x))
@> x a b c d e == e(d(c(b(a(x)))))

# Unlike |>, functions can have arguments - the value
# preceding a function will be treated as its first argument
@> x g(y, z) f == f(g(x, y, z))

@> x g f(y, z) == f(g(x), y, z)

# @>> does the exact same thing, but with value treated as the *last* argument.

@>> x g(y, z) f == f(g(y, z, x))

@>> x g f(y, z) == f(y, z, g(x))

# @as lets you name the threaded argument
@as x start_value f(x, y) g(z, x) == g(z, f(start_value, y))

# All threading macros work over begin blocks
```