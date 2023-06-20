  module.exports = {
    ci: {
      collect: {
        url: [
          // 'https://www.ausy.fr/fr/',
          'https://www.amazon.fr/gp/css/homepage.html?ref_=nav_youraccount_btn'
        ],
        headful: true,
        puppeteerScript: 'lighthouse_ci/puppeteer-script.js',
        settings: {
          disableStorageReset: true,
          onlyCategories: [
            'performance'
            // 'accessibility',
            // 'best-practices',
            // 'seo',
          ],
        },
      },
      // assert: {
      //   preset: 'lighthouse:no-pwa'
      // },
      upload: {
        // target: 'temporary-public-storage',
        target: 'filesystem',
        outputDir: 'rapport/'
      },
      // server: {
      //   // server options here
      // },
      // wizard: {
      //   // wizard options here
      // },
    },
  };