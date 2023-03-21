---
title: Tickets
description: Documentation for working with tickets.
---

<https://app.respondohub.com/tickets>

The ticket view is composed of three sections - the header, the main area and
the footer.

The header shows you which social media account is the source of the
ticket, the tags on a ticket and a dropdown for secondary actions.

The main part houses information about the ticket author, the ticket content,
the timestamp on a ticket and actions for showing the internal notes, assigning
and updating the ticket status.

The footer houses the ticket reply form.

## Filtering

### Searching by content

You can search tickets based on their content. Enter the search query to filter
by content, e.g. `content:Respondo is awesome` then press the Search button.

### Searching by author name

You can search tickets based on the author name. Enter the search query to
filter by author name, e.g. `author:matteeyah` then press the Search button.

### Filtering by status

You can filter tickets based on ther status. Click the "Open Tickets" or "Solved
Tickets" button.

### Filtering tickets assigned to you

You can filter tickets that are assigned to you. Click the "Assigned to me"
button.

### Filtering tickets with a tag

You can filter tickets that have a specific tag by clicking the tag name on any
ticket.

## Responding to tickets

### Replying

You can reply to social media posts. To respond to a post, type out your reply
in the reply form and click the send button (<i class="bi bi-telegram"></i>).

### Generating a response with AI

You can prompt the AI to generate a response.

If you want the AI to come up with a response completely on its own, click the
lightning (<i class="bi bi-lightning"></i>) button.

Example output:

```plain
Hello @twitter, thank you for reaching out to us at Respondo. How may I assist
you today?
```

If you want to give the AI guidelines for generating the response, enter a short
guideline in the response field then click the lightning
(<i class="bi bi-lightning"></i>) button.

Example guideline:

```plain
offer an amazon gift card for troubles
```

Example output:

```plain
Hello @twitter, thank you for reaching out to us. We apologize for any
inconvenience that you may have experienced. We would like to make it up to you
by offering you an Amazon gift card for the troubles. Please send us a private
message with your email address so we can send the gift card to you. Thank you
for your patience and understanding.
```

### Internal Notes

You can leave internal notes, visible only to other organization members. To open
the internal notes, click the note (<i class="bi bi-sticky"></i>) button below
the ticket you want to respond to.

### Solving / Re-Opening

You can Solve open tickets and Re-Open solved tickets. Select the ticket status
from the status dropdown and click Update.

### Tagging

You can tag a ticket to easily group related tickets. Adding a tag is done by
filling out the "add tag" field in the ticket header with the tag contents and
clicking on the plus sign (<i class="bi bi-plus"></i>). To remove a tag, just
click the x sign (<i class="bi bi-x"></i>) next to the tag that you want to
remove.

### Assigning

You can assign a ticket to a specific member of your team. Assigning is done by
selecting the team member from the assignment dropdown and clicking "Assign".

### Deleting

You can delete tickets by clicking the dropdown toggler
(<i class="bi bi-three-dots"></i>) in the ticket header then clicking on
"Delete".

### Opening the social media post

You can open the original social media post the ticket was created from by
clicking the dropdown toggler (<i class="bi bi-three-dots"></i>) in the ticket
header then clicking on "External View".

## Email Tickets

You can create tickets by sending an email. Just send an email to
`inbound+{ORGANIZATION_ID}@mail.respondohub.com`. Your `ORGANIZATION_ID` is
located in your organization settings page.

## Webhook Integrations

You can create tickets manually, just submit a POST request to
`https://app.respondohub.com/organizations/{ORGANIZATION_ID}/external_tickets.json`
using [this format](https://docs.respondohub.com/external_ticket_format).

You need a `Personal Access Token` for creating external tickets. Please see the
documentation for [managing personal access tokens](../users#personal-access-tokens).
