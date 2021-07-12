FROM python:3.8

COPY . /app

RUN pip install mlflow tensorflow
EXPOSE 5000
CMD python /app/build_model.py && mlflow ui --host 0.0.0.0