#!/usr/bin/env python3
import json
import os

import requests

# Mapping Open-Meteo WMO codes to your specific Nerd Font icons
# https://open-meteo.com/en/docs
weather_icons = {
    "0": "󰖙",  # Clear sky
    "1": "󰖙",  # Mainly clear
    "2": "",  # Partly cloudy
    "3": "",  # Overcast
    "45": "",  # Fog
    "48": "",  # Depositing rime fog
    "51": "",  # Drizzle: Light
    "61": "",  # Rain: Slight
    "63": "",  # Rain: Moderate
    "71": "",  # Snow fall: Slight
    "73": "",  # Snow fall: Moderate
    "95": "",  # Thunderstorm
    "default": "",
}


def get_location():
    try:
        response = requests.get("https://ipinfo.io/json", timeout=5)
        data = response.json()
        lat, lon = data["loc"].split(",")
        return lat, lon
    except:
        return "43.8509", "-79.0204"  # Default to Ajax, ON if IP lookup fails


def get_weather():
    lat, lon = get_location()

    # API call for current weather + daily (for min/max) + hourly (for rain chance)
    url = f"https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current_weather=true&hourly=precipitation_probability&daily=temperature_2m_max,temperature_2m_min,apparent_temperature_max&timezone=auto"

    try:
        response = requests.get(url, timeout=5)
        data = response.json()

        current = data["current_weather"]
        daily = data["daily"]

        # Extracting values
        temp = f"{round(current['temperature'])}°C"
        status_code = str(current["weathercode"])
        icon = weather_icons.get(status_code, weather_icons["default"])

        # Feels like (using daily max apparent as proxy or current)
        temp_feel = f"{round(daily['apparent_temperature_max'][0])}°C"

        # Min/Max
        temp_min = f"{round(daily['temperature_2m_min'][0])}°C"
        temp_max = f"{round(daily['temperature_2m_max'][0])}°C"

        # Wind & Humidity (Open-Meteo current includes windspeed)
        wind_speed = f"{current['windspeed']} km/h"
        # Precipitation chance for the current hour
        rain_chance = data["hourly"]["precipitation_probability"][0]

        # Construct Tooltip
        tooltip_text = (
            f'<span size="xx-large">{temp}</span>\n'
            f"<big> {icon}</big>\n"
            f"Feels like {temp_feel}\n\n"
            f"<b>  {temp_min}\t\t  {temp_max}</b>\n"
            f"  {wind_speed}\t {rain_chance}%\n"
        )

        # Waybar Output
        out_data = {
            "text": f"{icon}  {temp}",
            "alt": status_code,
            "tooltip": tooltip_text,
            "class": f"weather-{status_code}",
        }

        # Cache for other scripts
        simple_weather = (
            f"{icon} {temp}\nFeels: {temp_feel}\nMin/Max: {temp_min}/{temp_max}"
        )
        cache_path = os.path.expanduser("~/.cache/.weather_cache")
        with open(cache_path, "w") as file:
            file.write(simple_weather)

        return json.dumps(out_data)

    except Exception as e:
        return json.dumps({"text": "󰖙 --°C", "tooltip": f"Error: {str(e)}"})


if __name__ == "__main__":
    print(get_weather())
