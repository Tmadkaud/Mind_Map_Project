FROM python:3

WORKDIR /usr/src/mindmap

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD [ "python", "main.py" ]
