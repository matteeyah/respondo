---
layout: page
title: Documentation - Tickets
order: 4
---

# Working with Tickets

## Responding to tickets

### Personal account

If you aren't a member of a certain brand, you can respond to related tickets
from your personal account.

You will only be able to respond on the social network that is currently
authenticated in your `User settings`.

### Brand account

If you are a member of a certain brand, you will be able to respond to related
tickets and responses will be sent from the brand's social network handle.

You will also be able to solve tickets.

## Solving tickets

Every user of the related brand can mark tickets as solved. If somebody continues
the discussion on the ticket after that, it will be automatically moved to
`Open tickets`.

## Webhook Integrations

If you want to create a ticket manually, just submit a POST request to
`https://app.respondohub.com/brands/{BRAND_ID}/external_tickets.json` using
[this format](https://docs.respondohub.com/external_ticket_format).

You will need a `Personal Access Token` for creating external tickets. You can
review existing and create new tokens on the `User Settings` page.
