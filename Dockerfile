FROM python:3.8-slim-buster

WORKDIR app

COPY print_demo_directories.sh .

CMD [ "./print_demo_directories.sh" ]