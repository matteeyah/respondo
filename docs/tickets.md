---
layout: page
title: Documentation - Tickets
order: 4
---

# Working with tickets

## Responding to tickets

### Personal account

If you aren't a member of a certain brand, you can respond to related tickets
from your personal account.

You can only respond on the social network that is currently authenticated in
your `User settings`.

### Brand account

If you are a member of a certain brand, you can respond to related tickets.
Responses are sent from the brand's social network handle.

You can also solve tickets.

## Solving tickets

Every user of the related brand can mark tickets as solved. If somebody continues
the discussion on the ticket after that, it is automatically moved to
`Open tickets`.

## Webhook Integrations

If you want to create a ticket manually, just submit a POST request to
`https://app.respondohub.com/brands/{BRAND_ID}/external_tickets.json` using
[this format](https://docs.respondohub.com/external_ticket_format).

You need a `Personal Access Token` for creating external tickets. You can review
existing and create new tokens on the `User Settings` page.
