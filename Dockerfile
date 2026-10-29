FROM nginx:1.27-alpine
COPY site/ /usr/share/nginx/html/
ARG GIT_SHA=local
RUN echo "$GIT_SHA" > /usr/share/nginx/html/version.txt
EXPOSE 80