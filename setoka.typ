#import "@preview/touying:0.6.3": *
#import "@preview/fletcher:0.5.8" as fletcher

#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

#let slide(..args) = touying-slide-wrapper(self => {
  let header(self) = {
    set align(top)
    set text(size: 14pt)
    place(
      left + top,
      dx: 0.7em,
      dy: 0.7em,
      image("./assets/deco.svg", width: 2em, height: 2em),
    )
    place(
      left + top,
      dx: 3em,
      dy: 0.7em,
      image("./assets/deco.svg", width: 1em, height: 1em),
    )
  }
  let footer(self) = {
    set align(bottom)
    set text(fill: self.colors.neutral-darkest, size: 14pt)
    pad(x: 0.7em, y: 0.7em, {
      h(1fr)
      context utils.slide-counter.display() + " / " + utils.last-slide-number
    })
  }
  self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
    ),
  )
  touying-slide(self: self, ..args)
})

#let title-slide(..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let body = {
    set align(center)
    components.cell(
      fill: self.colors.neutral-darkest,
      width: 100%,
      height: 50%,
      inset: 0.5em,
      components.cell(
        width: 80%,
        height: 100%,
        {
          set align(bottom)
          set text(size: 1em, fill: self.colors.neutral-lightest, weight: "bold")
          info.title
        },
      ),
    )
    components.cell(
      width: 100%,
      height: 50%,
      {
        set align(horizon)
        set text(fill: self.colors.neutral-darkest, size: 0.5em)
        if info.author != none {
          block(info.author)
        }
        block()
        if info.subtitle != none {
          block(info.subtitle)
        }
        if info.date != none {
          block(utils.display-info-date(self))
        }
      },
    )
    set text(size: 14pt)
    place(
      left + top,
      dx: 0.7em,
      dy: 0.7em,
      image("./assets/deco.svg", width: 2em, height: 2em),
    )
    place(
      left + top,
      dx: 3em,
      dy: 0.7em,
      image("./assets/deco.svg", width: 1em, height: 1em),
    )
  }
  self = utils.merge-dicts(
    self,
    config-page(
      margin: 0pt,
    ),
  )
  touying-slide(self: self, body)
})

#let about-slide(..args) = slide({
  set align(center + horizon)
  [
    #text(size: 0.4em)[いまむら] \
    #text(size: 0.9em)[nsfisis] \
  ]
  image("./assets/me.svg", width: 2em, height: 2em)
})

#let setoka-theme(
  aspect-ratio: "16-9",
  footer: none,
  ..args,
  body,
) = {
  set text(size: 48pt)
  show link: underline

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: 2em,
    ),
    config-common(
      slide-fn: slide,
      slide-level: 0,
    ),
    config-colors(
      primary: rgb("#ffa500"),
      neutral-lightest: white,
      neutral-darkest: black,
    ),
    ..args,
  )

  body
}
