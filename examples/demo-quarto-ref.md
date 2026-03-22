---
title: alerts-normalize.lua demo
---

<!--
This file is the expected output of demo.md when processed by alerts-normalize.lua
in Quarto render mode. It uses native Quarto callout syntax directly — no filter
needed — so rendering it with quarto render is a quick sanity check: if it produces
styled callouts, the Quarto pipeline is working correctly. If demo.md produces the
same result, the filter is working correctly too.
-->

## Standard GitHub alert types

::: {.callout-note title="Note"}
Highlights information that users should take into account, even when
skimming.
:::

::: {.callout-tip title="Tip"}
Optional information to help a user be more successful.
:::

::: {.callout-important title="Important"}
Crucial information necessary for users to succeed.
:::

::: {.callout-warning title="Warning"}
Critical content demanding immediate user attention due to potential risks
or negative outcomes.
:::

::: {.callout-caution title="Caution"}
Negative potential consequences of an action.
:::

## Custom types

::: {.callout-spoiler title="Spoiler"}
Any uppercase word is accepted as an alert type.
:::

## Multi-paragraph alert

::: {.callout-note title="Note"}
First paragraph of the alert.

Second paragraph with **bold** and `code`.
:::

## Alert with a list

::: {.callout-tip title="Tip"}
You can include lists inside alerts:

-   item one
-   item two
-   item three
:::
