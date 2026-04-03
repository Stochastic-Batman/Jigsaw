# Jigsaw

[![OCaml](https://img.shields.io/badge/ocaml-5.4.0-orange.svg)](https://ocaml.org/releases/ocaml-5.4.html)

A file splitting & reconstruction utility. Jigsaw allows you to break a file into n pieces (shares) such that you only need a specific number of them (k) to get your original data back. If you have fewer than k pieces, you have nothing but random noise.

## How it works

### 1. The Custom Arithmetic (The Foundation)

Standard computer math doesn't work for this because adding or multiplying bytes often results in numbers larger than 255. We need our math to "stay" within the 0-255 range (the size of a single byte).

We treat every byte as a member of a special mathematical set where "addition" is actually just a bitwise XOR. Multiplication is more complex, so to keep the tool fast, we precompute how every byte relates to every other byte.

### 2. Precomputation (`precompute.ml`)

Before we can split a file, we need a "lookup book" for our custom math.

We run a script that generates two tables: a Log Table and an Exponential Table. These tables turn difficult multiplication problems into simple addition problems (similar to how slide rules work).

**The Workflow:** Our main program checks if these tables exist on your disk. If they don't, it triggers the precomputation logic automatically and saves the results to a file so it never has to do the hard work again.

### 3. Splitting a File (`./jigsaw --split`)

When we split your file, we aren't just cutting it into chunks.

For every single byte in your original file, we generate a unique, random "path" (a polynomial curve). We place the "secret" byte at the very start of this path (where the input is zero). We then pick n different points along that path and hand one point to each share file. Because of how these curves work, you need a specific number of points to "trace" the path back to the start.

### 4. Reconstructing a File (`./jigsaw --join`)

To get your file back, you provide at least k share files.

We read the points from your shares. We use a method called Interpolation to redraw the path that connects those points. Once the path is redrawn, we look at the very beginning of the curve (the starting point) to find the original byte. We do this for every byte until the entire file is reconstructed.

## Setup Instructions

### 1. Install OPAM

If you don't have the OCaml package manager yet, grab it here:

```bash
sh <(curl -sL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)
```

### 2. Initialize OCaml 5.4.0

I'm using a dedicated "switch" for this project to keep the OCaml 5.4 environment clean.

```bash
opam init -y
opam switch create jigsaw 5.4.0
eval $(opam env --switch=jigsaw)
```

### 3. Install Project Libraries

I need **Dune** to build the project:

```bash
opam install -y dune
```

### 4. Build and Run

Run the project using Dune:

```bash
dune build && dune exec bin/jigsaw
```

or, if the command above does not work for you, try:

```bash
dune build && dune exec bin/jigsaw.exe
```

### 5. Usage Example

```bash
dune exec bin/jigsaw.exe -- --split lorem_ipsum.txt 10 6
```

and restore it back via (use at least 6 files):

```bash
dune exec bin/jigsaw.exe -- --join restored.txt lorem_ipsum.txt.share_1 lorem_ipsum.txt.share_3 lorem_ipsum.txt.share_5 lorem_ipsum.txt.share_7 lorem_ipsum.txt.share_9 lorem_ipsum.txt.share_10
```

## File Structure

```text
jigsaw/
├── dune-project
├── bin/
│   ├── dune
│   └── jigsaw.ml
└── lib/
    ├── dune
    ├── precompute.mli / .ml
    ├── gf256.mli     / .ml
    ├── lagrange.mli  / .ml
    ├── slicer.mli    / .ml
    └── shares.mli    / .ml
```
