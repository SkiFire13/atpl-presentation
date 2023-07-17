#import "typst-slides/slides.typ": *
#import "typst-slides-unipd/unipd.typ": *

#set text(font: "New Computer Modern Sans")

#show: slides.with(
  title: "Safety in Rust",
  authors: "Giacomo Stevanato",
  date: "July 2023",
  aspect-ratio: "4-3",
  theme: unipd-theme(),
)

#show link: it => text(fill: unipd-red, underline(it))

#slide(theme-variant: "title")

#new-section("Introduction")

#slide(title: "Why Rust")[
  - Alternative to C/C++

  - Safe (no undefined behaviour by default)

  - Fast (compiled, no GC, thin abstractions over hardware)

  - Modern (union types, pattern matching, closures, etc etc)
]

#new-section("Core concepts")

#slide(title: "How does it work")[
  - Problem:

    - Mutability

    - Aliasing

    - Unrestricted

  - Solution:

    - Ownership

    - Borrowing and Lifetimes
]

#slide(title: "Ownership")[
  - Affine types

  - A value can be "consumed"/"moved" *at most once* \
    and cannot be used afterwards

  - Handle deallocation and release of resources

  ```rs
  let mut foo = vec![1, 2, 3];
  bar(foo);
  foo.push(4); // Error: `foo` has been consumed by `bar`
  ```
]

#slide(title: "Borrowing")[
  - What about:
    ```rs
    let mut foo = vec![1, 2, 3];
    foo.push(4);
    bar(foo);
    ```
  
  - Temporary access that don't consume values

  - Reference types

    - Shared: ```rs &'lft T ```

    - Exclusive: ```rs &'lft mut T ```
]

#new-section("Safety")

#slide(title: "But is it actually safe?")[
  - *RustBelt*

  - $lambda_"Rust"$ models a core subset of Rust

  - Proof of safety theorem in Coq

  - #link("https://plv.mpi-sws.org/rustbelt/popl18/")
]

// TODO: Other informations on RustBelt?

#slide(title: "What about the implementation?")[
  #box(inset: (x: -1%), width: 110%, ```rs
  fn bad<'t, T>(x: &'t T) -> &'static T {
    fn f<'a, 'b, T>(_: &'a &'b (), v: &'b T) -> &'a T { v }
    let g: for<'a, 'b, 'c> fn(&'a &'b (), &'c T) -> &'a T = f;
    g(&&(), x)
  }
  ```)
  #v(5%)
  #link("https://github.com/rust-lang/rust/issues/25860")
]

#new-section("Other features")

#slide(title: "Lifetime generics")[
  - What is the lifetime `'lft` here?
    #only(1, ```rs
    fn id(r: &'lft i32) -> &'lft i32 { r }
    ```)
  
  - `id` is valid for every lifetime `'lft`:
    ```rs
    fn id<'lft>(r: &'lft i32) -> &'lft i32 { r }
    ```

  - What is the type of `id` as a value?
    ```rs
    for<'lft> fn(&'lft i32) -> &'lft i32
    ```
]

#slide(title: "Subtyping")[
  - No structural or nominal subtyping

  - Lifetime subtyping

    #let r(it) = raw(lang: "rs", it)
    #let s = h(0.7em)

    - $#r("'long")#(`: `) #h(0.3em) #r("'short") #s -> #s #r("&'long T") #s <: #s #r("&'short T")$

    - $#r("for<'a> T<'a>") #s <: #s #r("T<'b>")$

    - $#r("T") #s <: #s #r("U") #s -> #s #r("for<'a> T") #s <: #s #r("for<'a> U")$
]

#slide(title: "Implied bounds")[
  - Types need to be well-formed

  - ```rs &'lft T``` is WF if ```rs T: 'lft```

  - Some code have to prove WF and other can assume it
]

#new-section("Safety")

#slide[
  #show: it => box(inset: (x: -5%), width: 110%, it)
  ```rs
  fn bad<'t, T>(x: &'t T) -> &'static T {
    // f type-checks thanks to the implied 'b: 'a bound
    fn f<'a, 'b, T>(_: &'a &'b (), v: &'b T) -> &'a T { v }
    // function pointer to f
    let g: for<'a, 'b> fn(&'a &'b (), &'b T) -> &'a T = f;
    // subtly invalid
    let h: for<'a, 'b, 'c> fn(&'a &'b (), &'c T) -> &'a T = g;
    // cast to supertype
    let j: fn(&'static &'static (), &'t T) -> &'static T = h;

    j(&&(), x)
  }
  ```
]

// TODO: everything

#slide(theme-variant: "end")[
  Thank you for your attention
]
