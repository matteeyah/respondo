---
layout: page
title: Documentation - Tickets
order: 4
---

# Working with tickets

If someone leaves a public reply on a ticket that's closed, it's automatically
re-opened.

## Responding to tickets

You can reply to social media posts. To open the response form, click the reply
(<i class="fas fa-reply"></i>) button below the ticket you want to respond to.

You can leave internal notes, visible only to other brand members. To open the
internal note form, click the note (<i class="fas fa-sticky-note"></i>) button
below the ticket you want to respond to.

You can Solve open tickets and Open solved tickets. Click the solve or open
(<i class="fas fa-check"></i>/<i class="fas fa-folder-open"></i>) button below
the ticket you want to change the status of. Only members of a brand can Solve
or Open tickets that belong to that brand. If you solve a ticket that has
replies, all of its descendants will automatically be solved as well. If you open
a ticket that has replies, all of its ascendants will automatically be opened as
well.

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
