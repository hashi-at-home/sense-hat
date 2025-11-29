from typing import Union
from sense_hat import SenseHat
from fastapi import FastAPI
from prometheus_client import Gauge, start_http_server


app = FastAPI()
sense = SenseHat()
sense.low_light = True


def get_sense_data():
    sense_data = []
    sense_data.append(sense.get_temperature_from_humidity())


@app.get("/")
def read_root():
    sense.show_message("Hello World")
    return {"Hello": "world"}


@app.get("/sense/health")
def read_sense_health():
    sense.show_message("OK")
    return "OK"


def main():
    sense.show_message(
        text_string="Hello World",
        scroll_speed=0.05,
        text_colour=[204, 255, 182],
        back_colour=[57, 28, 227],
    )


def shut_down():
    sense.clear()


if __name__ == "__main__":
    try:
        while True:
            main()
    except KeyboardInterrupt:
        shut_down()
        print("interrupted!")
