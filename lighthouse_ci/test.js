const puppeteer = require('puppeteer');

(async () => {
  // Launch a new browser instance
  const browser = await puppeteer.launch({headless: false});

  // Create a new page
  const page = await browser.newPage();

  // Navigate to a URL
  await page.goto('https://www.amazon.fr/ap/signin?openid.pape.max_auth_age=0&openid.return_to=https%3A%2F%2Fwww.amazon.fr%2F%3Fref_%3Dnav_signin&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.assoc_handle=frflex&openid.mode=checkid_setup&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&');

  await page.type('#ap_email', 'romuald.classeur@gmail.com');
  await page.click('span#continue');
  await page.waitForNavigation();
  
  await page.type('#ap_password', 'ausyforever');
  await page.click('#signInSubmit');
  await page.waitForNavigation();

  // Close the browser
  await browser.close();
})();

