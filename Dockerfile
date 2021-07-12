FROM python:3.8

COPY . /app

RUN pip install mlflow tensorflow
CMD python /app/build_model.py