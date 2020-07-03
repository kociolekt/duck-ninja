module.exports = {
  siteMetadata: {
    title: `Duck Ninja Game Site`,
    description: `Platformer Duck Ninja is in alpha draft pre-release and cannot be considered as final product in any way.`,
    author: `@kociolekt`,
  },
  plugins: [
    `gatsby-plugin-sass`,
    `gatsby-plugin-react-helmet`,
    {
      resolve: `gatsby-source-filesystem`,
      options: {
        name: `images`,
        path: `${__dirname}/src/images`,
      },
    },
    `gatsby-transformer-sharp`,
    `gatsby-plugin-sharp`,
    {
      resolve: `gatsby-plugin-manifest`,
      options: {
        name: `gatsby-starter-default`,
        short_name: `starter`,
        start_url: `/`,
        background_color: `#437D98`,
        theme_color: `#437D98`,
        display: `minimal-ui`,
        icon: `src/images/ninja_duck_page_icon.png`, // This path is relative to the root of the site.
      },
    },
    // this (optional) plugin enables Progressive Web App + Offline functionality
    // To learn more, visit: https://gatsby.dev/offline
    // `gatsby-plugin-offline`,
  ],
}
