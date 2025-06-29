FROM swift:5.5-focal
RUN apt-get update && apt-get install -y \
    inotify-tools \
    && rm -rf /var/lib/apt/lists/*
ENV BLOG_TARGET ${BLOG_TARGET:-ocean}
RUN mkdir /site
WORKDIR /site
COPY Makefile Makefile
COPY bin bin
COPY drafts drafts
COPY gensite gensite
COPY images images
COPY posts posts
COPY public public
COPY samhuri.net samhuri.net
RUN mkdir www
CMD ["bin/watch"]
