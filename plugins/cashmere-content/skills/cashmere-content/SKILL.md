---
name: cashmere-content
license: MIT
description: >
  Manage a publisher's content on Cashmere: upload books, PDFs, EPUBs, articles,
  web pages and XML to become searchable licensed "omnipubs"; attach metadata,
  external IDs (e.g. ISBN) and ONIX records; organize them into collections and
  tags; watch processing until content is searchable; fix failed or duplicate
  uploads; replace or retire titles; and grant licenses to the organizations
  that may use them. Use for bulk uploads, ingestion scripts, catalog cleanup,
  and "why isn't my book showing up" questions. For building apps that read
  Cashmere content use cashmere-developer; for usage and revenue numbers use
  cashmere-reporting.
---

# Manage content on Cashmere

A publisher uploads a file or a page. Cashmere parses it into an **omnipub**
(a structured publication with sections and blocks), indexes it, and serves
it to licensed AI products. The work here is getting content in cleanly,
knowing when it is ready, and controlling who can use it.

## Read the live docs

**The live Cashmere docs are the source of truth. Read them as part of the
task.** This skill gives direction. The docs carry the current fields,
formats, status codes and limits. Where this skill and the docs disagree, the
docs win.

- Start with the [documentation index](https://cashmere.io/docs/llms.txt).
  Read only the pages the task needs.
- Every guide is served as Markdown at `https://cashmere.io/docs/guides/<path>.md`.
- The API contract is
  [`https://cashmere.io/api/v2/openapi.json`](https://cashmere.io/api/v2/openapi.json).
  For a field name, an accepted value or a status code, the spec outranks the
  guides.
- If the index is unavailable, use the links below. If a `.md` fetch fails,
  fetch the HTML page. With no live access, say so and do not invent fields.

| Task | Start here |
| --- | --- |
| Overview of getting content in | [Publisher quickstart](https://cashmere.io/docs/guides/publishers/quickstart.md) |
| Upload through the dashboard | [Add content in the Cashmere console](https://cashmere.io/docs/guides/publishers/add-content-in-cashmere-console.md) |
| Upload through the API | [Add omnipubs via API](https://cashmere.io/docs/guides/developers/add-omnipubs-via-api.md), then `POST /omnipub` in the spec |
| Bulk ingest from storage | [Connect an S3 bucket](https://cashmere.io/docs/guides/publishers/connect-s3-bucket.md), [connect an SFTP server](https://cashmere.io/docs/guides/publishers/connect-sftp-server.md) |
| ISBN and ONIX metadata | [ONIX support](https://cashmere.io/docs/guides/publishers/onix-support.md), then `/metadata-records` in the spec |
| What an omnipub is | [What is an Omnipub](https://cashmere.io/docs/guides/omnipub.md) |
| Grant and manage licenses | [Managing licenses via API](https://cashmere.io/docs/guides/developers/managing-licenses-via-api.md) |
| Collections and tags | `/collections` and `/tags` in the spec |

## Set up access

- **Base URL:** `https://cashmere.io/api/v2`. Auth is
  `Authorization: Bearer <key>`.
- **Uploads need a Read & Write key from a publisher organization.** A
  Read-only key gets 403 on every write. The user creates keys at
  `https://cashmere.io/settings/api-keys`. You cannot. Ask, then wait.
- **Find the key** in the `CASHMERE_API_KEY` environment variable, or else
  in the key file `~/.config/cashmere/api-key` (`%APPDATA%\cashmere\api-key`
  on Windows). Never print, log or commit it. If neither has a key, follow
  step 3 of the [setup guide](https://cashmere.io/docs/guides/agent-setup.md).
  The key file is the easy route for users who don't work in a shell.
- **Keep the key out of command lines.** Send the header through stdin, for
  example `printf 'Authorization: Bearer %s\n' "$(cat ~/.config/cashmere/api-key)" | curl -H @- ...`.
  Scripts you write read the same variable or file.
- `GET /allowed-endpoints` shows what the key may call. Check it before
  debugging a 403.
- Some settings exist only in the dashboard (for example collection pricing).
  When the spec has no field for what the user wants, send them to the
  dashboard page and say which setting to change. Do not guess an API
  field.

## Plan the upload

Settle these before writing a loop over a thousand files:

- **One stable `external_id` per title**, such as the ISBN or the
  publisher's own ID. It is how you find the title again, poll its status,
  match ONIX records, and replace it later. The live docs give the
  uniqueness rules.
- **Pick the content source.** Send exactly one per request: a file, a
  `file_url` Cashmere downloads, raw HTML, or Markdown. The file type comes
  from the extension in the filename or URL path. A web page URL with no
  extension is rejected, so send its HTML instead.
- **Supply metadata you know.** Title, authors, publisher, dates, cover and
  source URL. Values you send override what the parser extracts, and they
  survive reprocessing.
- **Choose the collection up front.** Content is licensed by collection, so
  a title outside the right collection is invisible to the licensees who
  should see it. Upload into a manual collection. Dynamic collections fill
  themselves from rules and do not take direct uploads.
- **Start with a handful of files.** Upload three representative titles,
  wait for them to finish, open them, and check the structure and metadata.
  Only then run the batch.

## Watch processing

Upload returns 202 with a `uuid`. Processing runs in the background and can
take minutes for a large book.

- Poll `GET /omnipub/{uuid}/status`, or `GET /omnipub/by-external-id/{id}/status`.
  Back off between polls. Seconds apart is plenty, and a batch should poll
  in rounds, not per file in a tight loop.
- **Read `status_label` and `status_description`.** They say what is
  happening in words. Numeric codes are banded and have changed before; take
  their meaning from the live docs, not from memory.
- **Done** means indexed and searchable. **Failed** responses carry an
  `error_message`. A **duplicate** carries `duplicate_uuid` and
  `duplicate_type`, which point at the existing copy. That is usually the
  answer, not a bug.
- **"Held for license"** means the content is fine but will not be indexed
  until a license approves it.
- **Searchable is not the same as visible to you.** Search only returns
  licensed content, so a publisher sees its own titles in search only with a
  license to its own collection. "I uploaded it but search can't find it" is
  usually a missing license, not a failed upload.

## Change what is already there

- **Metadata:** `PUT /omnipub/{uuid}/metadata`.
- **Content:** a file cannot be edited in place. Retire the old omnipub, then
  upload the new file with the same `external_id`.
- **Retire:** the deprecate endpoint removes a title from use. There is no
  public hard delete. Confirm with the user before retiring anything, and
  only touch titles they named or that this session uploaded.
- **Collections and tags:** add and remove publications by UUID. Read the
  collection back afterwards and report the before and after counts.

## Licenses

A license grants an organization the use of collections under named rights.
Grant by organization slug or email, then approve or deny pending requests.
Licenses decide who pays for what, so never grant, widen or revoke one
without the user's explicit instruction. Read the license back after every
change and show it.

## Report like an operator

End a batch with a table, not a paragraph: how many were submitted, are
indexed, are still processing, failed (with `error_message`), and were
duplicates (with the existing UUID). List the failures by `external_id` so
the user can act on them. Never report a title as done until its status says
so.
