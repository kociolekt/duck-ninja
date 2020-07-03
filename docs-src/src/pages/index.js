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
        <a href="" target="_blank">for Windows</a>
      </div>
    </MainLayoutSide>
    <MainLayoutContainer>
      <div className="change-log">
        <h2 className="change-log__title">Changelog</h2>
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
