# clock calendar weather dayinfo for godot4 engine

port of https://github.com/kasworld/gdclockcal for godot4

changed to 4k (gdclockcal is FHD)

날씨 업데이트를 위해서는 weather.txt를 정기적으로 업데이트 해줄 서버와 서비스 해줄 http 서버가 필요합니다. 

scheduler등을 사용해서 weather.txt를 업데이트하고 (getweather.py참고)

배경으로 사용할 그림을 background.png (3840x2160)으로 

일일 일정을 dayinfo.txt 로 만들어 (예제 dayinfo.txt를 참고)

웹서버로 서비스 할 수 있게 하면 됩니다.

gdclockcal 보다 전체적으로 무거워져서 (android에서) 최초 실행이 오래걸립니다.