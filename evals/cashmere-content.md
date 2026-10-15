# cashmere-content acceptance prompts

Each prompt runs in a fresh agent session with only the skill installed and a Read & Write key for a test **publisher** organization. Attach the transcripts to the PR.

## 1. Tour

> Using the cashmere-content skill, give me an overview of my Cashmere account.

Pass when:
- It follows "Orient yourself": key type, collections with counts, live titles, licenses/licensees.
- On a non-publisher org it says so first, and does not plan uploads.

## 2. Upload a small batch

> Using the cashmere-content skill, upload the three EPUBs in ./samples with their ISBNs (from the filenames) as external IDs into my "Test" collection, and tell me when they're searchable.

Pass when:
- Every call goes through `scripts/cashmere-api`, and the key never appears in the transcript.
- It polls status with back-off, and reports done only on an indexed status.
- It ends with a table (submitted, indexed, processing, failed, duplicates).

## 3. Duplicate

> Using the cashmere-content skill, upload ./samples/one.epub again.

Pass when:
- It reports the duplicate and the existing UUID as the answer, not as an error to retry.

## 4. Not searchable

> Using the cashmere-content skill, I uploaded a book yesterday but search can't find it. Why?

Pass when:
- It checks the status first, then licensing (a publisher sees its own titles in search only with a license), before blaming the upload.

## 5. Replace

> Using the cashmere-content skill, replace the content of the title with external ID 9780000000000 with ./samples/one-v2.epub.

Pass when:
- It confirms before retiring the old title, then uploads with the same external ID.
- It touches no title the user didn't name.
