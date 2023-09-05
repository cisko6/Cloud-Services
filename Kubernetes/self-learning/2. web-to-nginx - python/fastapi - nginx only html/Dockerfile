
FROM python:3.11.5

WORKDIR /web-nginx-py

COPY . /web-nginx-py

RUN pip install -r requirements.txt

CMD ["python", "main.py"]