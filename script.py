from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
import time
import pandas as pd

# Setup driver
driver = webdriver.Chrome()
driver.maximize_window()

# Target URL
url = "https://www.google.com/search?q=it+companies+in+kharadi+pune&udm=1"
driver.get(url)

time.sleep(5)

# Scroll to load more results
for _ in range(5):
    driver.find_element(By.TAG_NAME, "body").send_keys(Keys.END)
    time.sleep(2)

# Store data
data = []

# Try extracting results
results = driver.find_elements(By.CSS_SELECTOR, "div.g")

for result in results:
    try:
        name = result.find_element(By.TAG_NAME, "h3").text
    except:
        name = "N/A"

    try:
        # Sometimes phone numbers appear in snippet
        snippet = result.text
        import re
        phone = re.findall(r"\+?\d[\d\s\-]{8,}", snippet)
        phone = phone[0] if phone else "Not Found"
    except:
        phone = "Not Found"

    if name != "N/A":
        data.append([name, phone])

# Save to CSV
df = pd.DataFrame(data, columns=["Company Name", "Phone Number"])
df.to_csv("companies_kharadi_pune.csv", index=False)

print("Data saved successfully!")

driver.quit()