from playwright.sync_api import sync_playwright
with sync_playwright() as p:
 browser=p.firefox.launch(headless=True)
 page=browser.new_page()
 errors=[]
 page.on('pageerror',lambda e:errors.append(str(e)))
 page.goto('http://127.0.0.1:3001',wait_until='domcontentloaded')
 page.locator('input[type="password"]').wait_for(state='visible',timeout=30000)
 assert not errors, 'Browser JavaScript errors occurred'
 browser.close()
print('PASS Firefox launch and rendered login page without JavaScript errors')
