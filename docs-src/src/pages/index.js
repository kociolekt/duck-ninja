import React from "react"
//import { Link } from "gatsby"

import MainLayout, { MainLayoutContainer, MainLayoutSide } from "../layouts/main-layout"
import SEO from "../components/seo"

const IndexPage = () => (
  <MainLayout>
    <SEO title="Home" />
    <h1 className="page-title">NINJA DUCK</h1>
    <MainLayoutSide>
      <div className="box">
        <h2 className="box__title">Download</h2>
        <a href="https://github.com/kociolekt/duck-ninja/releases/download/0.0.3/duck-ninja-windows.0.0.3.zip" target="_blank">for Windows</a><br/>
        <a href="https://github.com/kociolekt/duck-ninja/releases/download/0.0.3/duck-ninja-mac.0.0.3.zip" target="_blank">for Mac</a>
      </div>
    </MainLayoutSide>
    <MainLayoutContainer>
      <div className="change-log">
        <h2 className="change-log__title">Changelog</h2>
        <div className="change-log__entry">
          <h2 className="change-log__entry-title">alpha 0.0.3</h2>
          <p className="change-log__entry-description">
            Prepared map to be more challenging and changed companion.<br/>
          </p>
          <ul className="change-log__entry-list">
            <li>
              changed companion apprance and added animations
            </li>
            <li>
              new map generator
            </li>
            <li>
              
              export for mac
            </li>
          </ul>
        </div>
        <div className="change-log__entry">
          <h2 className="change-log__entry-title">alpha 0.0.2</h2>
          <p className="change-log__entry-description">
            Some tweaks fixes and updates.
          </p>
          <ul className="change-log__entry-list">
            <li>
              added icon
            </li>
            <li>
              added wall_hang, dash and wall_jump animation
            </li>
            <li>
              tweaked some walljumping values
            </li>
            <li>
              changed cat algorithm a little
            </li>
            <li>
              added walljumping
            </li>
            <li>
              added saving coins on ESC
            </li>
            <li>
              changed menu background
            </li>
          </ul>
        </div>
        <div className="change-log__entry">
          <h2 className="change-log__entry-title">alpha 0.0.1</h2>
          <p className="change-log__entry-description">
            Released first alpha version.
          </p>
          <ul className="change-log__entry-list">
            <li>
              added duck
            </li>
            <li>
              added companion cat
            </li>
            <li>
              added money! $$$
            </li>
            <li>
              map rendered from radom map pieces
            </li>
            <li>
              simp menu (mouse only)
            </li>
          </ul>
        </div>
      </div>
    </MainLayoutContainer>
  </MainLayout>
)

export default IndexPage
