/**
 * Creating a sidebar enables you to:
 - create an ordered group of docs
 - render a sidebar for each doc of that group
 - provide next/previous navigation

 The sidebars can be generated from the filesystem, or explicitly defined here.

 Create as many sidebars as you want.
 */

module.exports = {
  tutorialSidebar: [
    'intro',
    {
      type: 'category',
      label: 'Getting Started',
      items: [
        'getting-started/installation',
        'getting-started/configuration',
        'getting-started/basic-usage',
      ],
    },
    {
      type: 'category',
      label: 'Architecture',
      items: [
        'architecture/overview',
        'architecture/client-server',
        'architecture/entities',
      ],
    },
    {
      type: 'category',
      label: 'Client API',
      items: [
        'api/client/core',
        'api/client/cplayer',
      ],
    },
    {
      type: 'category',
      label: 'Server API',
      items: [
        'api/server/core',
        'api/server/splayer',
        'api/server/sinventory',
        'api/server/sequipment',
      ],
    },
    {
      type: 'category',
      label: 'Data Access Layer',
      items: [
        'dao/overview',
        'dao/player-dao',
        'dao/inventory-dao',
        'dao/equipment-dao',
      ],
    },
    {
      type: 'category',
      label: 'Shared Utilities',
      items: [
        'shared/config',
        'shared/utilities',
      ],
    },
    {
      type: 'category',
      label: 'Examples',
      items: [
        'examples/getting-player',
        'examples/inventory-management',
        'examples/equipment-system',
      ],
    },
  ],
};

