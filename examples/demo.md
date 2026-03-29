---
title: alerts-normalize.lua — full demo
---

## Standard GitHub alert types

> [!NOTE]
> Highlights information that users should take into account, even when skimming.

> [!TIP]
> Optional information to help a user be more successful.

> [!IMPORTANT]
> Crucial information necessary for users to succeed.

> [!WARNING]
> Critical content demanding immediate user attention due to potential risks or negative outcomes.

> [!CAUTION]
> Negative potential consequences of an action.


## Casing — any combination is accepted

> [!note]
> All lowercase.

> [!Note]
> First letter capitalised only.

> [!NOTE]
> All uppercase.


## Extended types

> [!INFO]
> Additional information.

> [!SUCCESS]
> Operation completed successfully.

> [!FAILURE]
> Something went wrong.

> [!DANGER]
> Danger zone.

> [!BUG]
> Known unexpected behaviour.

> [!EXAMPLE]
> A usage example.

> [!QUOTE]
> A relevant quotation.

> [!ABSTRACT]
> Summary of the content.

> [!HINT]
> A useful hint.

> [!TODO]
> Still to be completed.

> [!SEEALSO]
> See also the related documentation.

> [!SPOILER]
> Any uppercase word is accepted as a custom alert type.


## Inline title

> [!NOTE] This is the title
> Body of the alert.

> [!WARNING] Important notice
> The title sits on the same line as the marker.

> [!TIP] Title only, no body


## Collapse — collapsed, expanded, unmarked

> [!NOTE]-
> This alert starts collapsed.

> [!TIP]+
> This alert starts explicitly expanded.

> [!WARNING]
> No collapse marker — default behaviour.


## Collapse with title

> [!NOTE]- My collapsed note
> Content hidden by default.

> [!TIP]+ Expanded tip
> Visible from the start.


## Rich content — multiple paragraphs

> [!NOTE]
> First paragraph of the alert.
>
> Second paragraph with **bold** and `inline code`.
>
> Third paragraph.


## Rich content — lists

> [!TIP]
> You can include lists inside alerts:
>
> - item one
> - item two
> - item three


## Rich content — code block

> [!IMPORTANT]
> Install the dependencies before continuing:
>
> ```bash
> npm install
> npm run build
> ```


## Rich content — table

> [!NOTE]
> Format comparison:
>
> | Format      | Container   | Collapse |
> |-------------|-------------|----------|
> | Quarto      | Div         | ✓        |
> | GitHub      | BlockQuote  | ✓        |
> | MkDocs      | Admonition  | ✓        |
> | Sphinx      | Directive   | ✗        |


## Rich content — nested

> [!NOTE]
> An alert with complex content:
>
> ### Subsection
>
> Paragraph with a [link](https://example.com) and *italic* text.
>
> > A blockquote nested inside the alert.


## Empty alert

> [!NOTE]


## Passthrough — plain blockquotes are left untouched

> This is a regular blockquote, not an alert.

> Another one with **bold** that must not be transformed.


## Pandoc / Sphinx source — plain classed divs

### No title

::: {.note}
No title — auto-generated from class.
:::

::: {.warning}
No title.
:::

### Explicit title

::: {.note title="Explicit title"}
Title set via attribute.
:::

::: {.tip title="Another explicit title"}
Tip with explicit title.
:::

### Collapse — collapsed, expanded, unmarked

::: {.note collapse="true"}
Collapsed by default.
:::

::: {.tip collapse="false"}
Explicitly expanded.
:::

::: {.warning}
No collapse attribute — default behaviour.
:::

### Collapse with title

::: {.note title="My collapsed note" collapse="true"}
Collapsed with explicit title.
:::

::: {.tip title="Expanded tip" collapse="false"}
Expanded with explicit title.
:::

### Rich content

::: {.note title="Rich content"}
First paragraph.

Second paragraph with **bold** and `code`.

- item one
- item two
:::

### Empty

::: {.note}
:::


## Quarto source — callout-* divs

### No title

:::{.callout-note}
No title — Quarto auto-generates from class.
:::

:::{.callout-warning}
No title.
:::

### Explicit title

:::{.callout-note title="My Quarto title"}
Title set via attribute.
:::

:::{.callout-tip title="Another title"}
Tip with explicit title.
:::

### Collapse — collapsed, expanded, unmarked

:::{.callout-note collapse="true"}
Collapsed by default.
:::

:::{.callout-tip collapse="false"}
Explicitly expanded.
:::

:::{.callout-warning}
No collapse attribute — default behaviour.
:::

### Collapse with title

:::{.callout-note title="My collapsed note" collapse="true"}
Collapsed with explicit title.
:::

:::{.callout-tip title="Expanded tip" collapse="false"}
Expanded with explicit title.
:::

### Rich content

:::{.callout-note title="Rich content"}
First paragraph.

Second paragraph with **bold** and `code`.

- item one
- item two
:::

### Empty

:::{.callout-note}
:::


## Custom type — passes through unchanged if not in the whitelist

:::{.spoiler}
A custom type outside the whitelist passes through untouched.
:::

> [!SPOILER]
> A custom type from GitHub syntax — normalised anyway because the marker is unambiguous.
