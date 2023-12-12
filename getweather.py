#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import datetime
import time
import requests
from bs4 import BeautifulSoup

"""
https://weather.naver.com/

"""


def getNaverWeather():
    err = None
    currentTemperature = ""
    currentSky = ""
    geoLocation = ""
    # dust1 = ""
    # dust2 = ""
    try:

        # from weather page
        source = requests.get('https://weather.naver.com/')
        soup = BeautifulSoup(source.content, "html.parser")

        # find geoLocation
        location_name = soup.find('strong', {'class': 'location_name'})
        geoLocation = location_name.text.strip()
        
        weather_area = soup.find('div', {'class': 'weather_area'})
        
        # find currentTemperature 
        weather_now = weather_area.find('div', {'class': 'weather_now'})
        currentTemperature = weather_now.find(
            'strong', {'class': 'current'}).text.strip()

        # find currentSky
        currentSky = weather_now.find('span', {'class': 'weather'}).text.strip()
        
        # print(geoLocation,currentTemperature,currentSky )



        # # find dust1, dust2
        # weather_quick_area = weather_area.find('div', {'class': 'weather_quick_area'})
        # print(weather_quick_area)

        # weather_table = weather_quick_area.find('ul', {'class': 'weather_table'})
        # print("weather_table",weather_table)

        # # listair = weather_table[0].find_all('ul', {'class': 'weather_table'})
        # airlist = weather_table.find('dd', {'class': 'level4_1'})
        # dust1, dust2 = airlist[0].text, airlist[1].text

        return [currentTemperature, currentSky, geoLocation], []
    except Exception as e:
        print(e)
        return [], ["fail to get weather", repr(e)]


def getNaverWeatherRetry():
    tryCount = 10
    sleepDelaySec = 1.0
    while True:
        rtn,err = getNaverWeather()
        saveFile('weather.txt', rtn)
        saveFile('weather.err', err)
        if len(err) == 0:
            # rtn.append(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
            break
        else:
            tryCount -= 1
            if tryCount <= 0:
                break
            time.sleep(sleepDelaySec)

def saveFile(name, strList):
    with open(name, 'wt', encoding="utf-8") as f:
        for d in strList:
            f.write(d)
            f.write("\n")

getNaverWeatherRetry()
