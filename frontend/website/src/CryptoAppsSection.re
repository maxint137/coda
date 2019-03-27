let middleElementWidthRems = 13.75;

module Code = {
  let component = ReasonReact.statelessComponent("CryptoAppsSection.Code");
  let make = (~src, _children) => {
    ...component,
    render: _self =>
      <div
        className=Css.(
          style([
            display(`block),
            position(`relative),
            media(Style.MediaQuery.veryLarge, [width(`percent(40.0))]),
            // the "line"
            before([
              contentRule(""),
              zIndex(-1),
              display(`none),
              media(
                Style.MediaQuery.veryLarge,
                [
                  display(`block),
                  position(`absolute),
                  top(`percent(50.0)),
                  left(`percent(10.5)), // determined experimentally
                  width(`percent(100.0)),
                  height(`rem(0.125)),
                  backgroundColor(Style.Colors.blueBlue),
                ],
              ),
            ]),
          ])
        )>
        <pre
          className=Css.(
            style(
              Style.paddingX(`rem(1.0))
              @ Style.paddingY(`rem(1.0))
              @ [
                backgroundColor(Style.Colors.navy),
                color(Style.Colors.white),
                Style.Typeface.ibmplexmono,
                fontWeight(`medium),
                fontSize(`rem(0.8125)),
                borderRadius(`px(12)),
                lineHeight(`rem(1.25)),
                marginLeft(`rem(-0.25)), // optical centering
                media(
                  Style.MediaQuery.notMobile,
                  [
                    width(`rem(23.0)),
                    // nudge so code background looks nicer
                    marginRight(`rem(0.25)),
                    marginLeft(`rem(0.25)),
                  ],
                ),
              ],
            )
          )>
          {ReasonReact.string(src)}
        </pre>
      </div>,
  };
};

module ImageCollage = {
  let component =
    ReasonReact.statelessComponent("CryptoAppsSection.ImageCollage");
  let make = (~className, _children) => {
    ...component,
    render: _self =>
      <div
        className=Css.(
          merge([
            className,
            style([
              position(`relative),
              top(`zero),
              left(`zero),
              zIndex(-1),
              media(Style.MediaQuery.veryLarge, [position(`static)]),
            ]),
          ])
        )>
        <Image
          className=Css.(
            style([
              position(`relative),
              top(`zero),
              left(`zero),
              right(`zero),
              bottom(`zero),
              margin(`auto),
              maxWidth(`percent(100.0)),
            ])
          )
          name="/static/img/map"
        />
        <Image
          className=Css.(
            style([
              position(`absolute),
              top(`zero),
              left(`zero),
              right(`zero),
              bottom(`zero),
              margin(`auto),
              maxWidth(`percent(100.0)),
            ])
          )
          name="/static/img/centering-rectangle"
        />
        <Image
          className=Css.(
            style([
              position(`absolute),
              top(`zero),
              left(`zero),
              right(`zero),
              bottom(`zero),
              margin(`auto),
              maxWidth(`percent(100.0)),
            ])
          )
          name="/static/img/montage"
        />
      </div>,
  };
};

let component = ReasonReact.statelessComponent("CryptoAppsSection");
let make = _ => {
  ...component,
  render: _self => {
    <div
      className=Css.(
        style([
          marginTop(`rem(4.75)),
          media(Style.MediaQuery.full, [marginTop(`rem(8.0))]),
        ])
      )>
      <Title
        fontColor=Style.Colors.denimTwo
        text={js|Build global cryptocurrency apps with\u00A0Coda|js}
      />
      <div
        className=Css.(
          style([
            position(`relative),
            left(`zero),
            top(`zero),
            media(Style.MediaQuery.veryLarge, [top(`rem(-2.0))]),
          ])
        )>
        <ImageCollage
          className=Css.(
            style([
              display(`none),
              media(Style.MediaQuery.veryLarge, [display(`block)]),
            ])
          )
        />
        <div
          className=Css.(
            style([
              display(`flex),
              flexWrap(`wrapReverse),
              justifyContent(`spaceBetween),
              alignItems(`center),
              marginLeft(`auto),
              marginRight(`auto),
              marginBottom(`rem(2.0)),
              maxWidth(`rem(78.0)),
              media(
                Style.MediaQuery.notMobile,
                [justifyContent(`spaceAround)],
              ),
              // vertically/horiz center absolutely
              media(
                Style.MediaQuery.veryLarge,
                [
                  position(`absolute),
                  top(`percent(50.0)),
                  left(`percent(50.0)),
                  transforms([
                    `translateX(`percent(-50.0)),
                    `translateY(`percent(-50.0)),
                  ]),
                  width(`percent(100.0)),
                ],
              ),
            ])
          )>
          <Code
            src={|<script src="coda_api.js"></script>
<script>
  onClick(button)
     .then(() => Coda.requestWallet())
     .then((wallet) =>
       Coda.sendTransaction(wallet, ...))
</script>|}
          />
          // This keeps the right hand text aligned with the inclusive app section.
          <div
            className=Css.(
              style([
                width(`rem(middleElementWidthRems)),
                height(`rem(0.)),
                display(`none),
                media(Style.MediaQuery.veryLarge, [display(`block)]),
              ])
            )
          />
          <SideText
            paragraphs=[|
              "Empower your users with a direct secure connection to the Coda network.",
              "Coda will be able to be embedded into any webpage or app with just a script tag and a couple lines of JavaScript.",
            |]
            cta="Stay updated about developing with Coda"
          />
        </div>
        <ImageCollage
          className=Css.(
            style([
              display(`block),
              marginBottom(`rem(4.0)),
              media(Style.MediaQuery.veryLarge, [display(`none)]),
            ])
          )
        />
      </div>
    </div>;
  },
};
