test_url="https://democicdapp.herokuapp.com"
expected_title = "Demo Application"
import logging
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.firefox.webdriver import WebDriver
from selenium.webdriver.support.ui import WebDriverWait
import unittest
import time

class TitleChecker(unittest.TestCase):
    def setUp(self):
        self.driver = webdriver.Firefox()
    def test_title_correct(self):
        driver = self.driver
        driver.get(test_url)
        time.sleep(1)
        title = driver.title
        assert title == expected_title
    
    def test_ok_endpoint(self):
        driver = self.driver
        driver.get(test_url)
        ok_link = driver.find_element_by_xpath("/html/body/nav/div/ul/li[2]/a") 
        ok_link.click()
        time.sleep(10)
        url = driver.current_url
        assert url == test_url+"/ok"    
    
    def tearDown(self):
        self.driver.close()   
if __name__ == "__main__":
    unittest.main()