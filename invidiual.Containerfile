FROM scratch

ARG directory
ARG name

COPY ${directory} /modules/${name}