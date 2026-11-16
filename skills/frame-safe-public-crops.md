# frame-safe-public-crops: check every public screenshot and clip

**Why it exists.** Game captures carry things you did not mean to publish: account names, overlays, engine stats, codes on screen. We scanned every outward image and clip before it left the building.

## Before you publish a picture
1. Work from a copy. Never edit or publish the unedited original.
2. Crop out the corners where the capture tool and the engine draw things (account line, overlay, stats, build or version codes).
3. View the result by eye at full size. Do not trust a script alone.
4. Check the file name and the caption: no private names, codes or paths.

## For video
1. Mask every account or overlay corner on every frame (a fixed box drawn over the same region works for a locked capture).
2. Check the result by pulling one frame per second into a contact sheet and looking at all of them.
3. Check the audio for spoken private names or codes.
4. Keep the original private. Publish only the masked copy.

## Fit the destination
- Know the destination's size and ratio rules before you crop (thumbnails, banners, blog images).
- Keep text out of art-only variants.
- Leave a safe margin at the top and bottom.

## Gotchas
- "Collapsed" does not mean gone: a hidden UI element can re-show in a later frame. Look at the whole clip.
- Re-check after any re-export; a new render can reintroduce a corner you masked.
- Keep a short checklist in the repo so the next person repeats the same checks.

## Copy-paste: a contact sheet for checking a clip (ffmpeg)
One frame per second tiled into a sheet you can look at in one glance:
```
ffmpeg -i clip.mp4 -vf "fps=1,scale=320:-1,tile=6x10" -frames:v 1 sheet.png
```
Mask a fixed corner on every frame (drawbox over the region, then re-check the sheet):
```
ffmpeg -i clip.mp4 -vf "drawbox=x=0:y=0:w=360:h=80:color=black:t=fill" -c:a copy masked.mp4
```

## Copy-paste: pre-publish checklist
```
[ ] Working from a copy, not the original
[ ] Account/overlay/stats/version corners cropped or masked on every frame
[ ] Viewed by eye at full size (and the contact sheet for video)
[ ] File name and caption carry no private names, codes or paths
[ ] Right size and ratio for the destination; no text in art-only variants
[ ] Audio checked for spoken private names or codes
```
