from typing import Optional

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

origins = [
    "http://localhost",
    "http://localhost:3000",
    "http://localhost:8000"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.get("/recipes")
def read_recipe():

  recipe_collection = [
      {
        "name": "paneer biryani",
        "cooking_time": "20 minutes"
      },
      {
        "name": "pani puri",
        "cooking_time": "60 minutes"
      },
      {
        "name": "aloo paratha",
        "cooking_time": "40 minutes"
      },
      {
        "name": "oakra",
        "cooking_time": "35 minutes"
      },
      {
        "name": "chicken biryani",
        "cooking_time": "50 minutes"
      },
      {
        "name": "prawns curry",
        "cooking_time": "20 minutes"
      },
      {
        "name": "mutton curry",
        "cooking_time": "140 minutes"
      },
      {
        "name": "fish pakora",
        "cooking_time": "35 minutes"
      }
  ]
  return recipe_collection