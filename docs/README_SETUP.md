# Docusaurus Setup Instructions

This document explains how to set up and use the Docusaurus documentation site for TPNRP Core.

## Prerequisites

- Node.js >= 14.0.0 (Docusaurus 2.4.3 supports Node 14+)
- npm or yarn

## Installation

1. Navigate to the docs directory:
```bash
cd docs
```

2. Install dependencies:
```bash
npm install
```

## Development

Start the development server:
```bash
npm start
```

This will:
- Start a local development server (usually at http://localhost:3000)
- Open a browser window automatically
- Watch for file changes and hot-reload

## Building

Create a production build:
```bash
npm run build
```

This generates static files in the `build` directory.

## Preview Production Build

Preview the production build locally:
```bash
npm run serve
```

## Deployment

### GitHub Pages

1. Update `docusaurus.config.js`:
   - Set `url` to your GitHub Pages URL
   - Set `baseUrl` to your repository name (e.g., `/tpnrp-core/`)

2. Add to `package.json`:
```json
"scripts": {
  "deploy": "docusaurus deploy"
}
```

3. Deploy:
```bash
npm run deploy
```

### Other Hosting

Simply upload the `build` directory to your hosting service:
- Netlify
- Vercel
- Any static hosting service

## Customization

### Logo

Place your logo in `static/img/logo.svg` and update `docusaurus.config.js` if needed.

### Colors

Edit `src/css/custom.css` to customize colors and styling.

### Configuration

Edit `docusaurus.config.js` to customize:
- Site title and description
- Navigation links
- Footer
- Plugins

## Documentation Structure

Documentation pages are in `docs/docs/`:
- `intro.md` - Introduction
- `getting-started/` - Getting started guides
- `architecture/` - Architecture documentation
- `api/` - API reference
- `dao/` - Data Access Layer documentation
- `shared/` - Shared utilities documentation
- `examples/` - Code examples

The sidebar navigation is configured in `sidebars.js`.

