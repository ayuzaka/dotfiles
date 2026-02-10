* When creating a layout, think `grid` first.
  * Use the `grid-template` shorthand whenever possible
* If you use media queries, make sure to specify the SP as the base.
* Responsive
  * Use media queries if styles change depending on the page width.
  * Use container queries if styles change depending on the width of the parent element.
  * Don't implement media queries without instructions.
* Shorthands are prohibited unless explicitly specified.
  * For example, if you want to add `margin` to the top and bottom, write `margin-block: 1rem;` instead of `margin: 1rem 0;`.
* Minimize the specificity of base CSS.
  + Use cascade layers (`@layer`) as much as possible.
  + If it's difficult, utilize `:where`.
