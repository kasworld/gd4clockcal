import sys
from datetime import date
from datetime import datetime
from datetime import timedelta

## We'll try to use the local caldav library, not the system-installed
sys.path.insert(0, "..")
sys.path.insert(0, ".")

import caldav

caldav_url = "http://192.168.0.10:5000/caldav/kasw"
headers = {"X-MY-CUSTOMER-HEADER": "123"}
calendar_name = "My Calendar"
username = sys.argv[1]
password = sys.argv[2]

def get_todayinfo():
    result = []
    with caldav.DAVClient(
        url=caldav_url,
        username=username,
        password=password,
        headers=headers,  # Optional parameter to set HTTP headers on each request if needed
    ) as client:
        ## Typically the next step is to fetch a principal object.
        ## This will cause communication with the server.
        my_principal = client.principal()

        ## The principals calendars can be fetched like this:
        calendars = my_principal.calendars()

        for c in calendars:
            if c.name == calendar_name:
                events_fetched = c.search(
                    start=datetime.today() + timedelta(hours=11, seconds=1),
                    end=datetime.today(),# + timedelta(hours=23,minutes=59,seconds=59),
                    event=True,
                    expand=True,
                )
                for e in events_fetched:
                    result.append(e.icalendar_component["SUMMARY"])
                    print(e.data)

                    # for i in e.icalendar_component:
                    #     print(i, e.icalendar_component[i])
    return result

updateDateTime = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
result = get_todayinfo()
with open('todayinfo.txt', 'wt', encoding="utf-8") as f:
    for d in result:
        f.write(d)
        f.write("\n")
    f.write(updateDateTime)
