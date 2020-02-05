# Respondo Docs 8-)

>Ticketing system for social media posts
---

## Overview
[Respondo](https://matteeyah.com/respondo-website/) uses a ticket approach to social media (similar to Zendesk). You can filter tickets by status and search them by author name or content.

## Content
* Basic navigation
* Sign In
* Responding to tickets
  * Responding from the personal account
  * Responding from brand’s account
* Solving tickets
* Managing Brands
* Managing Users
* Additional integrations (using webhooks)

## Basic navigation
While signed out, you can see all [authenticated brands](https://respondo.herokuapp.com/brands), but can't respond to any ticket.

When you select one of the authenticated brands, you will be able to choose between `Open tickets` and `Solved tickets`.

[//]: # (explain what's the point of solving tickets)

Every time somebody mention brand's handle on any social network that is currently integrated with that brand's Respondo, a new ticket will be created under `Open tickets` view.

## Sign In
Authenticating is handled by Google OAuth. This allow users to easily sign in with just one click using their Google Account.

## Responding to tickets
### Responding from the personal account
If you aren't member of a certain brand, you can respond to related tickets from your personal account.

You will only be able to respond on the social network that is currently authenticated in your `User settings`.

### Responding from brand's account
If you are a member of a certain brand, you will be able to respond to related tickets and responses would be sent from brand's social network handle.

You would also be able to solve tickets if you think that the conversation is over.

## Solving tickets
Every user of the related brand can mark tickets as solved. If somebody continues the discussion on the ticket after that, it will be automatically be moved to `Open tickets` view.

## Managing brands
When you first sign in, you can click `Authorize Brand` and that will help you connect your brand to the Twitter account.

When signed in, you can load new tickets associated with your Brand by pressing `Refresh` button. 

Currently, we can automatically integrate your Twitter and Disqus. To do so, navigate to the `Brand Settings` page and you'll be able to authorize or deauthorize these accounts.

You can also add or remove users from your brand. All associated users will be able to respond to the related Brand tickets using auhorized Brand account on that social network.

After you connect your brand to a social network, last 20 mentions on that network will be pushed to the `Open tickets` view for context, and moving forward, a new ticket will be created for every new mention.

## Managing users
Currently, we can automatically integrate your Twitter, Disqus and Google. To do so, navigate to the `User Settings` page and you'll be able to authorize or deauthorize these accounts.

## Additional integrations (using webhooks)
If you want to create a ticket manually, just submit POST request to https://respondo.herokuapp.com/brands/4/external_tickets.json using [this format](https://github.com/matteeyah/respondo#external-tickets).

You will need `New Personal Access Tokens` for external tickets and you can review existing tokens or create a new one on `User Settings` page.