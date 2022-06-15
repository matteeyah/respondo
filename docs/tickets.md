---
title: Tickets
description: Documentation about working with tickets.
---

# Working with tickets

If someone leaves a public reply on a ticket that's closed, it's automatically
reopened.

## Filtering

### Searching by content

You can search tickets based on their content. Enter the search query then press
the Search button.

### Searching by author name

You can search tickets based on the author name. Enter the search query then
press the Search button.

### Filtering by status

You can filter tickets based on ther status. Click the "Open Tickets" or "Solved
Tickets" button to filter tickets.

## Responding to tickets

### Replying

You can reply to social media posts. To open the response form, click the reply
(<i class="fas fa-reply"></i>) button below the ticket you want to respond to.

### Internal Notes

You can leave internal notes, visible only to other brand members. To open the
internal note form, click the note (<i class="fas fa-sticky-note"></i>) button
below the ticket you want to respond to.

### Solving / Re-Opening

You can Solve open tickets and Re-Open solved tickets. Click the solve or reopen
(<i class="fas fa-check"></i>/<i class="fas fa-folder-open"></i>) button below
the ticket you want to change the status of. Only members of a brand can Solve
or Reopen tickets that belong to that brand. If you solve a ticket that has
replies, all of its descendants will automatically be solved as well. If you
reopen a ticket that has replies, all of its ascendants will automatically be
reopened as well.

### Personal account

If you aren't a member of a certain brand, you can respond to related tickets
only from your personal account.

You can only respond on the social network that is currently authenticated in
your `User settings`.

### Brand account

If you are a member of a certain brand, you can respond to related tickets from
the brand's social network account.

## Webhook Integrations

If you want to create a ticket manually, just submit a POST request to
`https://app.respondohub.com/brands/{BRAND_ID}/external_tickets.json` using
[this format](https://docs.respondohub.com/external_ticket_format).

You need a `Personal Access Token` for creating external tickets. Please see the
documentation for [managing personal access tokens](../users#personal-access-tokens).
