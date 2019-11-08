# Postit

#### Ett messageboard där inläggen ligger som post-it lappar under varandra

**gäster** kan skapa ett konto eller logga in

**användare** kan *se* och *göra* inlägg

**administratör** kan utöver det som användare kan *ta bort* inlägg samt *användare*

**inlägg** har ett *id*, *användare*, *innehåll*, *taggar* och en *referens* ifall det är ett svar till ett annat inlägg

**Filter** kan baseras på *id*, *användare* och *taggar*. När det **filtreras** baserat på *id* följer även *referenser* med.

