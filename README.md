# Advent of code, 2024

Languages:

1. [Zig](https://ziglang.org)
2. [Odin](https://odin-lang.org)
3. [Janet](https://janet-lang.org)
4. [Python](https://python.org)
5. [Janet](https://janet-lang.org) - Again. Tried [Gleam](https://gleam.run) but
   no (see below).

## Running with Zig

Zig version used is current master when the code was written.

Example run:

```
cd 1
zig build run
```

## Running with Odin

Odin version is 2024-11.

Example run:

```
cd 2
odin run .
```

## Running with Janet

Janet version is 1.36.0-homebrew.

```
cd 3
janet solution.janet
```

## Running with Python (uv)

Python version is 3.13.

```
cd 4
uv run --with pytest solution.py
```

## Hare

Hare doesn't work in Mac OS, otherwise I would have used it. :(

## Gleam

For day 5 I tried using Gleam. I installed it via Homebrew and got version
1.6.2. First I tried to just `gleam run` a gleam file, but that didn't work: I
need a project. So I ran `gleam new` followed by `gleam run`, and was met by a
wall of deprecation warnings. That was enough of a bad first impression to make
me decide not to use Gleam, and so I did another one in Janet which I had a
better experience with.
