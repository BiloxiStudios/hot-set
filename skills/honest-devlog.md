# honest-devlog: a build log that never claims more than someone saw

**Why it exists.** We wrote fourteen dated devlog entries in three days, plus a postmortem. The labels and habits below kept them honest.

## The shape of an entry
- Dated heading, with a headline that says what happened.
- One line of time left (for example "seven hours to the deadline").
- The news, in order of importance, every claim labelled:
  - **PLAYED**: a person ran it.
  - **BUILT**: it compiles and a second person read it.
  - **NOT seen**: neither.
- A closing **NOT seen yet** list, and a line saying when the next entry is due.
- About 400 to 900 words. Plain sentences, no hype.

## Habits
- Say what broke and why in one sentence. If the cause was wrong, replace it; do not defend it.
- Never write "submitted", "fixed" or "heard" without a receipt from the person who did it.
- Credit by role unless each person has OK'd their name. Get a person's own OK before quoting them.
- Keep private things private: codes, accounts, internal paths.
- Re-count numbers before you post (a count in prose drifts).
- One time zone, stated once.

## The review loop
Draft, scan for private details, have a second reader fix the facts, then publish. Later changes (pictures, wording) go into the existing dated section.

## Pictures
Plain captions, public-safe crops only (see frame-safe-public-crops).

## Postmortem
Sections: what we built, a timeline table, what worked, what did not (cause, cost, what we would change), starter tips. Fact-check every technical claim with the person who read the code.

## Copy-paste: an entry template
```
## <Day>, <time>: <a headline that says what happened>
<One line of time left.> Labels: PLAYED = a person ran it. BUILT = it compiles and a second person read it. NOT seen = neither.

- <News item> (PLAYED / BUILT / NOT seen)
- <What broke, in one sentence, and the cause if proven> (label)

**NOT seen yet:** <list>
Next entry about <time>.
```

## Copy-paste: AGENTS.md lines
```
- Every claim in a status or devlog carries PLAYED / BUILT / NOT seen.
- Never write "submitted", "fixed" or "heard" without a receipt from the person who did it.
- Credit by role unless the person OK'd their name; get their OK before quoting them.
- Scan for private details before publishing; re-count any number you quote.
```
