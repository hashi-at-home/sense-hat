from sense_hat import SenseHat
from prometheus_client import Gauge, start_http_server
from fastapi import FastAPI

app = FastAPI()
sense = SenseHat()
sense.low_light = True


@app.get("/")
def read_root():
    return {"Hello": "world"}


def get_sense_data():
    sense_data = []
    sense_data.append(sense_data.get_temperature_from_humidity())


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
