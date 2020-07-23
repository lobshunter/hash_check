FROM alpine:latest

RUN apk update && \
    apk add bash && \
    apk add curl && \
    apk add git && \
    apk add sshpass  

CMD [ "bash", "ls" ]