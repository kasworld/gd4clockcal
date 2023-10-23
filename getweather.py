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
    err = None
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

        return currentTemperature, currentSky, geoLocation, err
    except Exception as e:
        print(e)
        return "fail to get weather", repr(e),  "",   "", "", e


def getNaverWeatherRetry():
    tryCount = 10
    sleepDelaySec = 1.0
    rtn = getNaverWeather()
    while rtn[-1] != None:
        time.sleep(sleepDelaySec)
        rtn = getNaverWeather()
        tryCount -= 1
        if tryCount <= 0:
            break

    return rtn[:-1]


rtn = getNaverWeatherRetry()
updateDateTime = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

with open('weather.txt', 'wt', encoding="utf-8") as f:
    for d in rtn:
        f.write(d)
        f.write("\n")
    f.write(updateDateTime)
