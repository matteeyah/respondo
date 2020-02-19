# Respondo Docs 8-)

> Ticketing system for social media posts

---

## Overview

[Respondo](https://matteeyah.com/respondo-website/) uses a ticket approach to social media (similar to Zendesk). You can filter tickets by status and search them by author name or content.

## Content

* [Basic navigation](#basic-navigation)
* [Sign In](#sign-in)
* [Responding to tickets](#responding-to-tickets)
  * [Personal account](#personal-account)
  * [Brand account](#brand-account)
* [Solving tickets](#solving-tickets)
* [Managing Brands](#managing-brands)
* [Managing Users](#managing-users)
* [Webhook Integrations](#webhook-integrations)

## Basic navigation

While signed out, you can see all [authenticated brands](https://respondo.herokuapp.com/brands), but can't respond to any ticket.

When you select one of the authenticated brands, you will be able to choose between `Open tickets` and `Solved tickets`.

[//]: # (explain what's the point of solving tickets)

Every time somebody mentions the brand's handle on any social network that is currently integrated with that brand's Respondo, a new ticket will be created under `Open tickets`.

## Sign In

Authentication is handled exclusively with OAuth. This allows the users to easily sign in with just one click using one of their social accounts.

## Responding to tickets

### Personal account

If you aren't a member of a certain brand, you can respond to related tickets from your personal account.

You will only be able to respond on the social network that is currently authenticated in your `User settings`.

### Brand account

If you are a member of a certain brand, you will be able to respond to related tickets and responses will be sent from the brand's social network handle.

You will also be able to solve tickets.

## Solving tickets

Every user of the related brand can mark tickets as solved. If somebody continues the discussion on the ticket after that, it will be automatically moved to `Open tickets`.

## Managing brands

When you first sign in, you can click `Authorize Brand` and that will help you connect your brand Twitter account.

When signed in, you can load new tickets associated with your Brand by pressing the `Refresh` button.

Currently, we can automatically integrate your Twitter and Disqus accounts. To do so, navigate to the `Brand Settings` page and you'll be able to authorize or deauthorize these accounts.

You can also add or remove users from your brand. All associated users will be able to respond to the related Brand tickets using authorized Brand account on that social network.

## Managing users

Currently, we can automatically integrate your Twitter, Disqus and Google accounts. To do so, navigate to the `User Settings` page and you'll be able to authorize or deauthorize these accounts.

## Webhook Integrations

If you want to create a ticket manually, just submit a POST request to `https://app.respondohub.com/brands/{BRAND_ID}/external_tickets.json` using [this format](https://github.com/matteeyah/respondo#external-tickets).

You will need a `Personal Access Token` for creating external tickets. You can review existing and create new tokens on the `User Settings` page.
