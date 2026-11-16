"""Count a persona's registered-actions text before you push (UEFN Persona, 2000-character limit).

Counts every @ai_description string in the response structs you register, plus the Name and
Description text of each prompt_binding_definition. Field names and enum values do NOT count.
Over 2000 the NPC goes silent with no compile error, so this warns at 1900 and fails above 2000.

usage: python check_action_budget.py FILE.verse [FILE.verse ...] [--struct a,b] [--warn 1900] [--limit 2000]
  --struct  only count @ai_description inside these structs (the ones this persona registers)
exit code: 0 ok, 1 warn, 2 over the limit
"""
import argparse
import re
import sys

STR = r'"((?:[^"\\]|\\.)*)"'
STRUCT = re.compile(r'^(\w+)(?:<[^>]*>)*\s*:=\s*struct\b')
TOPLEVEL = re.compile(r'^\S')
DESC = re.compile(r'@ai_description\(\s*' + STR + r'\s*\)')
BINDING = re.compile(r'prompt_binding_definition')
FIELD = re.compile(r'^\s*(Name|Description)\s*:=\s*\w*\(?\s*' + STR)


def text_len(raw):
    # Verse escapes (\" \\ \n) are one character each in the text the model sees.
    return len(re.sub(r'\\(.)', r'\1', raw))


def scan(path, structs):
    rows = []
    current = None
    binding_lines = 0
    with open(path, encoding='utf-8') as f:
        for n, line in enumerate(f, 1):
            m = STRUCT.match(line)
            if m:
                current = m.group(1)
            elif TOPLEVEL.match(line) and not line.lstrip().startswith(('#', '@')):
                current = None
            for d in DESC.finditer(line):
                if structs is None or current in structs:
                    rows.append((text_len(d.group(1)), f'{path}:{n} {current}'))
            if BINDING.search(line):
                binding_lines = 4
                continue
            if binding_lines:
                binding_lines -= 1
                b = FIELD.match(line)
                if b:
                    rows.append((text_len(b.group(2)), f'{path}:{n} binding {b.group(1)}'))
    return rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('files', nargs='+')
    ap.add_argument('--struct', default=None)
    ap.add_argument('--warn', type=int, default=1900)
    ap.add_argument('--limit', type=int, default=2000)
    a = ap.parse_args()
    structs = set(a.struct.split(',')) if a.struct else None
    rows = [r for p in a.files for r in scan(p, structs)]
    total = sum(n for n, _ in rows)
    for n, where in sorted(rows, reverse=True)[:10]:
        print(f'{n:5d}  {where}')
    print(f'TOTAL {total} / {a.limit} ({len(rows)} strings)')
    if total > a.limit:
        print('OVER: the persona will go silent. Shorten descriptions or move detail into enum values.')
        return 2
    if total >= a.warn:
        print(f'WARN: within {a.limit - total} of the limit.')
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
