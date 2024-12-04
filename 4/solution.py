import pytest

WORD = "XMAS"

tests = [
("""
...S...
..A.A..
.M...M.
X.....X
""", 2),
("""
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
""", 18),
]

def count_em(data: str):
    total = 0
    lines = data.split()
    w, h = len(lines[0]), len(lines) 
    for y in range(0, h):
        for x in range(0, w):
            for word in [WORD, WORD[::-1]]:
                wlen = len(word)
                if lines[y][x] != word[0]:
                    continue
                if lines[y][x:].startswith(word):
                    total += 1
                v = "".join(lines[c][x] for c in range(y, min(y + wlen, h)))
                if v == word:
                    total += 1
                d = "".join(lines[c][d]
                           for c, d in zip(
                               range(y, min(y + wlen, h)),
                               range(x, min(x + wlen, w))))
                if d == word:
                    total += 1
                dr = "".join(lines[c][d]
                           for c, d in zip(
                               range(y, min(y + wlen, h)),
                               range(x, max(x - wlen, -1), -1)))
                if dr == word:
                    total += 1
    return total

def day2(data: str):
    swords = ["MAS", "SAM"]
    wlen = 3
    total = 0
    lines = data.split()
    w, h = len(lines[0]), len(lines) 
    for y in range(0, h):
        for x in range(0, w):
            for word in swords:
                if lines[y][x] != word[0]:
                    continue
                d = "".join(lines[c][d]
                           for c, d in zip(
                               range(y, min(y + wlen, h)),
                               range(x, min(x + wlen, w))))
                if d == word:
                    x2 = x + 2
                    if x2 >= w:
                        continue
                    for word2 in swords:
                        dr = "".join(lines[c][d]
                                for c, d in zip(
                                    range(y, min(y + wlen, h)),
                                    range(x2, max(x2 - wlen, -1), -1)))
                        if dr == word2:
                            total += 1
                            break
    return total

@pytest.mark.parametrize("data,expected", tests)
def test_day1(data, expected):
    result = count_em(data)
    assert result == expected

def main():
    data = open("input.txt").read()
    xmases = count_em(data)
    print(f"xmases={xmases}")
    masxes = day2(data)
    print(f"masxes={masxes}")


if __name__ == "__main__":
    main()
