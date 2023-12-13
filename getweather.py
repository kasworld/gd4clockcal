#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import datetime
# import time
import requests
# from bs4 import BeautifulSoup
import sys
import json


def saveFile(name, strList):
    with open(name, 'wt', encoding="utf-8") as f:
        for d in strList:
            f.write(d)
            f.write("\n")


"""
{
    "response": {
        "body": {
            "dataType": "JSON",
            "items": {
                "item": [
                    {
                        "baseDate": "20231213",
                        "baseTime": "1400",
                        "category": "PTY",
                        "nx": 63,
                        "ny": 126,
                        "obsrValue": "0"
                    },
                    {
                        "baseDate": "20231213",
                        "baseTime": "1400",
                        "category": "REH",
                        "nx": 63,
                        "ny": 126,
                        "obsrValue": "56"
                    },
                    {
                        "baseDate": "20231213",
                        "baseTime": "1400",
                        "category": "RN1",
                        "nx": 63,
                        "ny": 126,
                        "obsrValue": "0"
                    },
                    {
                        "baseDate": "20231213",
                        "baseTime": "1400",
                        "category": "T1H",
                        "nx": 63,
                        "ny": 126,
                        "obsrValue": "10.1"
                    },
                    {
                        "baseDate": "20231213",
                        "baseTime": "1400",
                        "category": "UUU",
                        "nx": 63,
                        "ny": 126,
                        "obsrValue": "0.2"
                    },
                    {
                        "baseDate": "20231213",
                        "baseTime": "1400",
                        "category": "VEC",
                        "nx": 63,
                        "ny": 126,
                        "obsrValue": "354"
                    },
                    {
                        "baseDate": "20231213",
                        "baseTime": "1400",
                        "category": "VVV",
                        "nx": 63,
                        "ny": 126,
                        "obsrValue": "-1.9"
                    },
                    {
                        "baseDate": "20231213",
                        "baseTime": "1400",
                        "category": "WSD",
                        "nx": 63,
                        "ny": 126,
                        "obsrValue": "2"
                    }
                ]
            },
            "numOfRows": 1000,
            "pageNo": 1,
            "totalCount": 8
        },
        "header": {
            "resultCode": "00",
            "resultMsg": "NORMAL_SERVICE"
        }
    }
}
["response"]["body"]["items"]["item"]
{'baseDate': '20231213', 'baseTime': '1400', 'category': 'PTY', 'nx': 63, 'ny': 126, 'obsrValue': '0'}
{'baseDate': '20231213', 'baseTime': '1400', 'category': 'REH', 'nx': 63, 'ny': 126, 'obsrValue': '57'}
{'baseDate': '20231213', 'baseTime': '1400', 'category': 'RN1', 'nx': 63, 'ny': 126, 'obsrValue': '0'}
{'baseDate': '20231213', 'baseTime': '1400', 'category': 'T1H', 'nx': 63, 'ny': 126, 'obsrValue': '10'}
{'baseDate': '20231213', 'baseTime': '1400', 'category': 'UUU', 'nx': 63, 'ny': 126, 'obsrValue': '-0.3'}
{'baseDate': '20231213', 'baseTime': '1400', 'category': 'VEC', 'nx': 63, 'ny': 126, 'obsrValue': '18'}
{'baseDate': '20231213', 'baseTime': '1400', 'category': 'VVV', 'nx': 63, 'ny': 126, 'obsrValue': '-1.9'}
{'baseDate': '20231213', 'baseTime': '1400', 'category': 'WSD', 'nx': 63, 'ny': 126, 'obsrValue': '1.3'}

초단기실황
T1H 기온 ℃ 10
RN1 1시간 강수량 mm 8
UUU 동서바람성분 m/s 12
VVV 남북바람성분 m/s 12
REH 습도 % 8
PTY 강수형태 코드값 4 강수형태(PTY) 코드 : (초단기) 없음(0), 비(1), 비/눈(2), 눈(3), 빗방울(5), 빗방울눈날림(6), 눈날림(7) 
VEC 풍향 deg 10
WSD 풍속 m/s 10
"""
pty2str = {
    "0": "",
    "1": "비",
    "2": "비/눈",
    "3": "눈",
    "5": "빗방울",
    "6": "빗방울눈날림",
    "7": "눈날림",
}


def getFromDataPotal(apikey, nx, ny):
    now = datetime.datetime.now() - datetime.timedelta(minutes=30)
    starDt = now.strftime("%Y%m%d")
    starHh = "%02d%02d" % (now.hour, now.minute)
    # print(starDt," ", starHh)

    rtn = []

    url = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst'
    params = {'serviceKey': apikey, 'pageNo': '1', 'numOfRows': '1000',
              'dataType': 'JSON', 'base_date': starDt, 'base_time': starHh, 'nx': nx, 'ny': ny}
    response = requests.get(url, params=params)
    if response.status_code != 200:
        print(response.status_code)
        exit()
    info = json.loads(response.content)
    infodict = {}
    for a in info["response"]["body"]["items"]["item"]:
        key = a["category"]
        vel = a["obsrValue"]
        infodict[key] = vel
    print(infodict)
    rtn.append("온도%s℃" % infodict["T1H"])
    rtn.append("습도%s%%" % infodict["REH"])
    rtn.append("풍속%sm/s" % infodict["WSD"])
    if infodict["PTY"] != "0":
        rtn.append("%s %smm" % [infodict["PTY"], infodict["RN1"]])

    print(rtn)
    # print(json.dumps(info, sort_keys=True, indent=4))

    saveFile('weather.txt', rtn)
    # saveFile('weather.err', err)


def getWeather():
    if len(sys.argv) != 4:
        print("need apikey and geocode")
        exit()

    apikey = sys.argv[1]
    nx = sys.argv[2]
    ny = sys.argv[3]

    getFromDataPotal(apikey, nx, ny)


getWeather()
